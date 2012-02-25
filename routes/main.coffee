module.exports = (app) ->
  app.get '/', (req, res) ->
    res.render 'index', {title: 'Express'}
  
#  app.get '/chat' (req, res) ->
#    
  
  app.post '/', (req, res) ->
    console.log 'post /'
    console.log req.body
    res.send req.body
  
  app.post app.API_PREFIX+'/login', (req, res) ->
    res.send app.user.login req.body.name
  
  app.post app.API_PREFIX+'/say', (req, res) ->
    res.send app.user.say req.body.user, req.body.msg
