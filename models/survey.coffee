mongojs = require "mongojs"
db      = mongojs("mongodb://dkhaburdzania:jina2009@ds051447.mongolab.com:51447/survey", ["surveys", "users"])

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
 
  @add_answer: (id, answers, ip, cb) ->
    update = 
      $push: { ips: ip, answers: {ip, answers, date: new Date()} }
    db.surveys.update _id: +id, update, (err, result) ->
      cb(err, result) 

  @get_last_id: (cb) ->
    db.surveys.find({},{_id: 1}).sort _id: -1, (err, doc) ->
      if doc?.length is 0
        cb(null, 0)
      else
        cb(err, doc?[0]?["_id"])

  @insert: (obj, cb) ->
    db.surveys.insert obj, (err) ->
      cb(err)

  @delete: (id, cb) ->
    db.surveys.remove {_id: id}, (err) ->
      cb(err?)

  @results: (id, cb) ->
    db.surveys.find {_id: id}, {answers: 1, surveys: 1, _id: -1}, (err, result) ->
      cb(err, result)

  @user: (username, cb) ->
    db.users.find user: username, (err, user) ->
      cb(err, user)


module.exports = Survey
