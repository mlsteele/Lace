module.exports = (app) ->
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'Lace'
      subtitle: 'Chat visualization experiment.'
      stylesheets: ['/css/index.css']
  
  app.get '/chat', (req, res) ->
    res.render 'chat',
      title: 'Lace | Chat'
      scripts: ['/socket.io/socket.io.js', '/vendor/jquery-1.7.1.min.js',
                '/vendor/underscore-min.js', '/js/chat.js']
      stylesheets: ['/css/chat.css']
