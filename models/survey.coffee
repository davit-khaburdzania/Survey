mongo = require "mongojs"
db    = mongo "survey-app", ["surveys", "users"]

class Survey
  @all: (cb) ->
    db.surveys.aggregate [
      $sort: "date": -1
    ], (err, surveys) ->
      cb(err, surveys)
    
  @one: (id, cb) ->
    db.surveys.find _id: +id, (err, survey) =>
      cb(err, survey)
  
  @ip_exists: (id, ip, cb) ->
    db.surveys.find _id: +id, ips: ip, (err, survey) ->
      cb(err, (survey?.length is 1))
 
  @add_answer: (id, answer, ip, cb) ->
    update = 
      $push: { ips: ip, answers: {ip, answer, date: new Date()} }
    db.surveys.update _id: +id, update, (err, result) ->
      cb(err, result) 

  @get_last_id: (cb) ->
    db.surveys.find({},{_id: 1}).sort _id: -1, (err, doc) ->
      if doc?.length is 0
        cb(null, 0)
      else
        cb(err, doc?[0]?["_id"])

  @insert: (obj, cb) ->
    obj.answers = obj.ips = []
    db.surveys.insert obj, (err) ->
      cb(err)

  @user: (username, cb) ->
    db.users.find user: username, (err, user) ->
      cb(err, user)


module.exports = Survey
