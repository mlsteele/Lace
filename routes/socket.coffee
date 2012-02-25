module.exports = (app) ->
  io = (require 'socket.io').listen app
  io.set 'log level', 1
  
  io.sockets.on 'connection', (socket) ->
    console.log 'socket connected'
    socket.on 'set name', (name, cb) ->
      console.log socket
      user = app.users.join
        name: name,
        uniq: socket.id,
        sendMsg: (msg) -> socket.emit 'chat msg', msg
        sendList: (list) -> socket.emit 'chat list', list
      
      console.log 'user created from socket named ' + user.name
      
      socket.on 'chat msg', (msg) ->
        console.log 'chat message from socket of user named ' + user.name + ' -> ' + msg.msg
        app.users.recvMsg user, msg
      
      socket.on 'disconnect', ->
        console.log 'socket disconnected of user named ' + user.name
        app.users.leave user
      
      cb? user
