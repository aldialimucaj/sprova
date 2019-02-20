ENV_FILE=".env"
MONGO_BOOTSTRAP_FILE="mongo_init/collections.js"

PASSWORD_LENGTH=20
PASSWORD_TEMPLATE="#password#"
JWT_TEMPLATE="#jwt_secret#"


# reset config files
function reset {
    mv $MONGO_BOOTSTRAP_FILE "$MONGO_BOOTSTRAP_FILE.del"
    cp "$MONGO_BOOTSTRAP_FILE.template" $MONGO_BOOTSTRAP_FILE
    mv $ENV_FILE "$ENV_FILE.del"
    cp "$ENV_FILE.template" $ENV_FILE

    echo "Config files successfully reseted"
}

# provision passwords
function provision {
    # test if files are pristine
    if ! grep -Fq "$PASSWORD_TEMPLATE" $ENV_FILE
    then
        echo "Error $PASSWORD_TEMPLATE was not found in $ENV_FILE"
        exit 1
    fi

    if ! grep -Fq "$JWT_TEMPLATE" $ENV_FILE
    then
        echo "Error $JWT_TEMPLATE was not found in $ENV_FILE"
        exit 1
    fi

    if ! grep -Fq "$PASSWORD_TEMPLATE" $MONGO_BOOTSTRAP_FILE
    then
        echo "Error $PASSWORD_TEMPLATE was not found in $MONGO_BOOTSTRAP_FILE"
        exit 1
    fi
    
    cp -n $ENV_FILE "$ENV_FILE.template"
    cp -n $MONGO_BOOTSTRAP_FILE "$MONGO_BOOTSTRAP_FILE.template"

    # generated password
    GENERATED_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!$/()=?+%<>*:;' | fold -w $PASSWORD_LENGTH | head -n 1)
    # generated jwt secret
    JWT_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!$/()=?+%<>*:;' | fold -w $PASSWORD_LENGTH | head -n 1)
    echo ""
    echo -e "Database password: \t\e[31m$GENERATED_PWD\e[0m"
    echo -e "JWT Secret: \t\e[31m$GENERATED_PWD\e[0m"
    echo ""

    sed -i "s/$PASSWORD_TEMPLATE/$GENERATED_PWD/g" $ENV_FILE
    sed -i "s/$PASSWORD_TEMPLATE/$GENERATED_PWD/g" $MONGO_BOOTSTRAP_FILE

    echo "Provisioning successful"
}

if grep -Fq "$PASSWORD_TEMPLATE" $ENV_FILE && grep -Fq "$PASSWORD_TEMPLATE" $MONGO_BOOTSTRAP_FILE
then
    echo "Provisioning:"
    provision
else
    if [ "$1" = "reset" ] 
    then
        echo "Resetting:"
        reset
    else
        echo "Provisioning is not possible because template $PASSWORD_TEMPLATE was not found"
        echo "This could mean that you have already generated a password for this installation."
        echo "If you want to reset the files call provision.sh reset"
        exit 1
    fi
fi
