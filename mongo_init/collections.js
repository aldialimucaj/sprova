db.users.insert({
    "_id" : ObjectId("5ae05f37dda5971dc20c9e21"),
    "username" : "admin",
    "password" : "76106072fec2dfd0ffd323154df459f9e90f1e58e66aba0c0282996278a4f4baad4802f6718765d589b0fe55333d73eb2fc898b31aaf1ecc61c4657e6101f01c",
    "firstname" : "Administrator",
    "lastname" : "Administrator",
    "status" : "active",
    "email" : "admin",
    "admin" : true,
    "createdAt" : ISODate("2018-01-01T11:11:11.111Z")
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
