survey = require __dirname + "/../models/survey"

## show all surveys
exports.all = (req, res) ->
  survey.all (err, surveys) ->
    res.render "index", surveys: surveys or []


## show specific survey
exports.survey_get = (req, res) ->
  id = req.params.id
  survey.one id, (err, s) ->
    if err or s.length isnt 1
      res.render "404"
    else
      ip = req.ip
      survey.ip_exists id, ip, (err, exists) ->
        if not exists? then exists = false;
        res.render "survey", {survey: s[0], exists}


## survey submited
exports.survey_post = (req, res) ->
  id = req.params.id
  ip = req.ip
  answers = req.body?.answers

  if ip? and id? and answers? and answers.indexOf('') is -1
    survey.one id, (err, s) ->
      ## check if survey exists
      if not s? or s.length <= 0  or s?[0]?.surveys?.length isnt answers.length
        res.json errors: ["You must answer all of surveys."]
        return
      ##if  user can submit multiple times
      if s[0].vote_multiple is "true"
        survey.add_answer id, answers, ip, (err) ->
          res.json errors: if err then ["something bad happend"] else null
      else
        ## check ip already exists
        survey.ip_exists id, ip, (err, exists) ->
          if exists
            res.json errors: ["you have already submited"]
          else
            survey.add_answer id, answers, ip, (err) ->
              res.json errors: if err then ["something bad happend"] else null
  else
    res.json errors: ["You must answer all of surveys."], result: false



## admin routes
exports.admin_get = (req, res) -> res.render "admin"



## authenticate user
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



## logout user
exports.logout = (req, res) ->
  req.session.destroy ->
    res.redirect "/"



## create new survey
exports.create_survey = (req, res) ->
  survey_name   = req.body.name
  surveys       = req.body.surveys
  vote_multiple = req.body.vote_multiple
  errors        = []


  if not surveys? or surveys?.length < 1 or not survey_name or not vote_multiple?
    errors = ["You must fill in all of the fields."]
    res.json errors: errors, okay: false
  else
    for s in surveys

      # if survey is list radio
      if s.type is "list_radio" or s.type is "list_dropdown"
        s.option_count = +s.option_count
        s.options = []

        if s.option_count > 0
          for i in [1..s.option_count]
            if not s["option#{i}"]? or s["option#{i}"]?.length is 0
              errors = ["You must fill in all of the fields."]
            s.options.push s["option#{i}"]

      #if survey is yes or no
      if s.type is "yes_or_no"
        s.options = ["Yes", "No", "No Answer"]
      
      #if survey is 5 point or 5 star
      if s.type is "5_point" or s.type is "5_star"
        s.options = [1, 2, 3, 4, 5]

      #if survey is percent survey
      if s.type is "percent"
        s.options = ["0-25", "26-50", "51-75", "76-100"]

      #if survey is Short Text or Long Text survey
      if s.type is "text_short" or s.type is "text_long"
        s.options = []


      #check for errors
      if not s.question or s.question.length < 1
        errors = ["You must fill in all of the fields."]
      if not s.type or s.type.length < 1
        errors = ["You must fill in all of the fields."]
      if s.type is "list_radio" and (not s.option_count or s.option_count < 2)
        errors = ["You must fill in all of the fields."]
      
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
        obj.vote_multiple = vote_multiple

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



## delete survey
exports.delete_survey = (req, res) ->
  id = +req.body.id
  survey.delete id, (err) ->
    res.json okay: not err



## survey results
exports.survey_results = (req, res) ->
  id = +req.params.id

  survey.results id, (err, data) ->
    if data.length is 1
      data = data[0]
      result = []

      ## add options to result
      for s in data.surveys
        survey_i = []
        for option in s.options
          survey_i.push {q: option, percent: 0, count: 0}
        result.push survey_i

      ## count survey answers
      for all_answer in data.answers
        for a, i in all_answer.answers
          if !isNaN(parseFloat(+a)) and isFinite(+a)
            result[i]?[+a]?.count++


      ## calculate percents
      count = data.answers.length
      for s, i in result
        for o, j in s
          option_count = o.count
          result[i][j].percent = 100/(count/option_count)

      res.json({error: null, result})

    else 
      res.json(error: "something bad happend", result: null)
