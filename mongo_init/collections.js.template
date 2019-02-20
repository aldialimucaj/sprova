db.users.insert({
    "username" : "admin",
    "password" : "#admin_pwd#",
    "firstname" : "Administrator",
    "lastname" : "Administrator",
    "status" : "active",
    "email" : "admin",
    "admin" : true,
    "createdAt" : ISODate("2019-01-01T11:11:11.111Z")
});

db.createUser(
  {
    user: "sprova",
    pwd: "#password#",
    roles: [
       { role: "readWrite", db: "sprova" }
    ]
  }
)
