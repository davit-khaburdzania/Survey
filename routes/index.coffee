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
  answer = req.body?.answer

  if ip? and id? and answer?
    survey.ip_exists id, ip, (err, exists) ->
      if exists
        res.json errors: ["you have already submited"]
      else
        survey.add_answer id, answer, ip, (err) ->
          res.json errors: if err then ["something bad happend"] else null
  else
    res.json errors: ["something missing"], result: false

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
  name      = req.body.name
  question  = req.body.question
  type      = req.body.type
  errors    = []

  # if survey is list radio
  if type is "list_radio"
    option_count = +req.body.option_count
    options = []
    if option_count > 0
      for i in [1..option_count]
        if not req.body["option#{i}"] or req.body["option#{i}"].length is 0
          errors.push "option #{i} is not filled"
        options.push req.body["option#{i}"]
  if type is "yes_or_no"
    options = ["Yes", "No"]

  #check for errors
  if not name or name.length < 1
    errors.push "please fill name field"
  if not question or question.length < 1
    errors.push "please fill question field"
  if not type or type.length < 1
    errors.push "please select one of the types"
  if type is "list_radio" and (not option_count or option_count < 2)
    errors.push "number of options must be more than 2"
  
  if errors.length > 0
    res.json errors:errors, okay: false
  else
    survey.get_last_id (err, id) ->
      if err
        res.json errors: ["can't get last id"], okay: false
      else
        ## insert survey into database
        obj =
          name:     name
          question: question
          type:     type
          options:  options
          date:     new Date()
          _id:      id+1

        survey.insert obj, (err) ->
          if err 
            res.json errors: ["soemthing bad happend"], okay: false
          else
            res.json errors: null, okay: true



