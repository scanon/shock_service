var cursor = db.Nodes.find()
while (cursor.hasNext()) { var doc = cursor.next(); db.Nodes.update({_id: doc._id}, {$set: {last_modified : new Date(doc.last_modified)}}) }
var cursor = db.Nodes.find()
while (cursor.hasNext()) { var doc = cursor.next(); db.Nodes.update({_id: doc._id}, {$set: {created_on : new Date(doc.created_on)}}) }
var cursor = db.Nodes.find({"last_modified": {"$lte": new ISODate("0000-00-00T00:00:00Z")}})
while (cursor.hasNext()) { var doc = cursor.next(); db.Nodes.update({_id: doc._id}, {$set: {last_modified : new ISODate("0000-00-00T00:00:00Z")}}) }
