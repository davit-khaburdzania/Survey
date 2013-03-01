## todo
# change survey:id to match regex
# better way to get last id 
# add indexes to db
express = require "express"
less    = require "less-middleware"
coffee  = require "coffee-middle"
routes  = require __dirname + "/routes"
app     = express()

# app configuration
# app.set "env", "production"

if app.get("env") is "development"
  app.use coffee 
    dest: __dirname + '/public/js'
    src: __dirname + "/public/coffee"

  app.use less 
    dest: __dirname + '/public/css'
    src: __dirname + "/public/less"
    prefix: "/css"
    compress: true
    force: true

app.set("views", __dirname + "/views")
app.set("view engine", "jade")
app.use(express.bodyParser())

app.use express.cookieParser '@viri@'
app.use express.session()
app.use (req, res, next) ->
  res.locals.user = req.session.user or null
  next()

app.use(express.methodOverride())
app.use(app.router)
app.use(express.static(__dirname + "/public"))

## check if user have access
if_not_logined = (req, res, next) ->
  if not req.session.user
    res.redirect "/admin"
  else
    next()

# main routes
app.get  "/",              routes.all

app.get  "/survey/:id",    routes.survey_get
app.post "/survey/:id",    routes.survey_post

app.get  "/admin",         routes.admin_get
app.post "/admin",         routes.admin_post
app.get  "/logout",        routes.logout

app.post "/create/survey", if_not_logined, routes.create_survey

app.listen "3000", ->
  console.log("server listening at port 3000...")