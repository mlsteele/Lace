module.exports = (app) ->
  io = (require 'socket.io').listen app
  io.set 'log level', 1
  
  (io.of app.API_PREFIX + '/socks/chat').on 'connection', (socket) ->
    console.log 'chat socket connected'
    socket.on 'set name', (name, beUser) ->
      console.log 'socket name set to', name
      user =
        name: name,
        uniq: socket.id,
        sendMsg: (msg) -> socket.emit 'chat msg', msg
        sendList: (list) -> socket.emit 'chat list', list
      beUser user
      app.users.join user
      
      console.log 'user created from socket named ' + user.name
      
      socket.on 'chat msg', (msg) ->
        console.log 'chat message from socket of user named ' + user.name + ' -> ' + msg.msg
        msg.from = user
        app.users.passMsg msg
      
      socket.on 'disconnect', ->
        console.log 'socket disconnected of user named ' + user.name
        app.users.leave user
