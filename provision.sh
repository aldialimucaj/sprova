TEMPLATE="template"
ENV_FILE=".env"
ENV_FILE_TPL="$ENV_FILE.$TEMPLATE"
MONGO_BOOTSTRAP_FILE="mongo_init/collections.js"
MONGO_BOOTSTRAP_FILE_TPL="$MONGO_BOOTSTRAP_FILE.$TEMPLATE"

PASSWORD_LENGTH=20
PASSWORD_TEMPLATE="#password#"
ADMIN_PASSWORD_TEMPLATE="#admin_pwd#"
JWT_TEMPLATE="#jwt_secret#"

set -e

function verifyProgram {
    if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo "$1 is required but not found. Attempting to installed if it fails install manually to proceede."
        echo "sudo apt-get install $1;"
        sudo apt-get install $1;
    fi
}

# backup config files
function backup {
    TIMESTAMP=$(date +%s)
    if [ -f $MONGO_BOOTSTRAP_FILE ] 
    then
        mv $MONGO_BOOTSTRAP_FILE "$MONGO_BOOTSTRAP_FILE.$TIMESTAMP.del"
        echo "Old configuration for $MONGO_BOOTSTRAP_FILE backed up. Make sure to delete it if it contains sensitive inforation."
    fi
    if [ -f $ENV_FILE ] 
    then
        mv $ENV_FILE "$ENV_FILE.$TIMESTAMP.del"
        echo "Old configuration for $ENV_FILE backed up. Make sure to delete it if it contains sensitive inforation."
    fi
}

# provision passwords
function provision {
    # test if files are pristine
    if ! grep -Fq "$PASSWORD_TEMPLATE" $ENV_FILE_TPL
    then
        echo "Error $PASSWORD_TEMPLATE was not found in $ENV_FILE_TPL"
        exit 1
    fi

    if ! grep -Fq "$JWT_TEMPLATE" $ENV_FILE_TPL
    then
        echo "Error $JWT_TEMPLATE was not found in $ENV_FILE_TPL"
        exit 1
    fi

    if ! grep -Fq "$PASSWORD_TEMPLATE" $MONGO_BOOTSTRAP_FILE_TPL
    then
        echo "Error $PASSWORD_TEMPLATE was not found in $MONGO_BOOTSTRAP_FILE_TPL"
        exit 1
    fi
    
    backup

    cp -n $ENV_FILE_TPL $ENV_FILE
    cp -n $MONGO_BOOTSTRAP_FILE_TPL $MONGO_BOOTSTRAP_FILE 

    # generated password
    GENERATED_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!?:;_=' | fold -w $PASSWORD_LENGTH | head -n 1)
    # generated jwt secret
    GENERATED_JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!?:;_=' | fold -w $PASSWORD_LENGTH | head -n 1)
    # generate admin pwd based on jwt secret
    verifyProgram "openssl"
    ADMIN_INITIAL_PWD=$(echo -n "admin" | openssl sha512 -hmac "$GENERATED_JWT_SECRET" | sed "s/(stdin)= //")
    
    echo ""
    echo -e "Database password: \t\e[31m$GENERATED_PWD\e[0m"
    echo -e "JWT Secret: \t\t\e[31m$GENERATED_JWT_SECRET\e[0m"
    echo ""

    cp "$ENV_FILE.template" $ENV_FILE
    cp "$MONGO_BOOTSTRAP_FILE.template" $MONGO_BOOTSTRAP_FILE

    sed -i "s/$PASSWORD_TEMPLATE/$GENERATED_PWD/g" $ENV_FILE
    sed -i "s/$JWT_TEMPLATE/$GENERATED_JWT_SECRET/g" $ENV_FILE
    sed -i "s/$PASSWORD_TEMPLATE/$GENERATED_PWD/g" $MONGO_BOOTSTRAP_FILE
    sed -i "s/$ADMIN_PASSWORD_TEMPLATE/$ADMIN_INITIAL_PWD/g" $MONGO_BOOTSTRAP_FILE

    echo "Provisioning successful"
}

if grep -Fq "$PASSWORD_TEMPLATE" "$ENV_FILE.template" && grep -Fq "$PASSWORD_TEMPLATE" "$MONGO_BOOTSTRAP_FILE.template"
then
    echo "Provisioning:"
    provision
else
    echo "Provisioning is not possible because template $PASSWORD_TEMPLATE was not found"
    echo "This could mean that you have already generated a password for this installation."
    echo "If you want to reset the files call provision.sh reset"
    exit 1
fi
