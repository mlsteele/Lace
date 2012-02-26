(require './util/compile-coffee') __dirname+'/client-coffee', __dirname+'/public/js'
require './util/timers'
express = require 'express'

module.exports = app = express.createServer();

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.set 'view options', { scripts: [], stylesheets: [] }
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', ->
  app.use express.errorHandler()

app.API_PREFIX = '/api/0.1'
(require './users') app
(require './routes/main') app
(require './routes/socket') app

if !module.parent
  port = if 0 <= process.argv[2] <= 65535 then process.argv[2] else 3000
  #host = if process.argv[3]?.length then process.argv[3] else '0.0.0.0'
  app.listen port
  console.log 'Express server listening on port ' + app.address().port
