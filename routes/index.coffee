survey = require __dirname + "/../models/survey"

## survey routes
exports.all = (req, res) ->
  survey.all (err, surveys) ->
    res.render "index", surveys: surveys or []

exports.survey_get = (req, res) ->
  id = req.params.id
  survey.one id, (err, survey) ->
    if err or survey.length isnt 1
      res.render "404"
    else
      res.render "survey", survey: survey[0]

exports.survey_post = (req, res) ->
  id = req.params.id
  ip = req.ip
  answers = req.body?.answers

  if ip? and id? and answers? and answers.indexOf('') is -1
    survey.one id, (err, s) ->
      ## check if survey exists
      if not s? or s.length <= 0  or s?[0]?.surveys?.length isnt answers.length
        res.json errors: ["please fill surveys"]
        return
      ## check ip already exists
      survey.ip_exists id, ip, (err, exists) ->
        if exists
          res.json errors: ["you have already submited"]
        else
          survey.add_answer id, answers, ip, (err) ->
            res.json errors: if err then ["something bad happend"] else null
  else
    res.json errors: ["please fill surveys"], result: false

##admin routes
exports.admin_get = (req, res) -> res.render "admin"

exports.admin_post = (req, res) ->
  user     = req.body.user
  password = req.body.password
  survey.user user, (err, user) ->
    if err
      res.json errors: ["something bad happend"], okay: false
    else if user.length isnt 1
      res.json errors: ["user dosn't exist"], okay: false 
    else if user[0].password is password
      req.session.user = user
      res.json errors: null, okay: true
    else
      res.json errors: ["password is incorrect"], okay: false 

exports.logout = (req, res) ->
  req.session.destroy ->
    res.redirect "/"


  ## create new survey
exports.create_survey = (req, res) ->
  survey_name = req.body.name
  surveys     = req.body.surveys
  errors      = []

  if not surveys? or surveys?.length < 1 or not survey_name
    errors = ["please fill all values"]
    res.json errors: errors, okay: false
  else
    for s in surveys
      # if survey is list radio
      if s.type is "list_radio"
        s.option_count = +s.option_count
        s.options = []

        if s.option_count > 0
          for i in [1..s.option_count]
            if not s["option#{i}"]? or s["option#{i}"]?.length is 0
              errors = ["please fill all values"]
            s.options.push s["option#{i}"]
      #if survey is yes or no
      if s.type is "yes_or_no"
        s.options = ["Yes", "No"]
      #check for errors
      if not s.question or s.question.length < 1
        errors = ["please fill all values"]
      if not s.type or s.type.length < 1
        errors = ["please fill all values"]
      if s.type is "list_radio" and (not s.option_count or s.option_count < 2)
        errors = ["please fill all values"]
      
  if errors.length > 0
    res.json errors:errors, okay: false
  else
    survey.get_last_id (err, id) ->
      if err
        res.json errors: ["can't get last id"], okay: false
      else
        ## insert survey into database
        obj = {}
        obj.name = survey_name
        obj.surveys = []
        obj.date = new Date()
        obj._id  = id+1
        obj.ips  = obj.answers = []

        for o in surveys
          obj.surveys.push
            question: o.question
            type:     o.type
            options:  o.options

        survey.insert obj, (err) ->
          if err 
            res.json errors: ["soemthing bad happend"], okay: false
          else
            res.json errors: null, okay: true



