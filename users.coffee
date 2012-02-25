# This is what a user has:
# name
# send -- a way to send messages to them

_U = require 'underscore'

users = []
usersExcept = (user) -> _U.without users, user

module.exports = (app) ->
  app.users =
    join: (user) ->
      if (_U.detect users, (u) -> u.uniq is user.uniq)?
        throw 'cannot register user who is already in users'
      users.push user
      console.log 'added user named ' + user.name
      console.log 'user count: ' + users.length
      user
    
    leave: (user) ->
      u.send user.name + ' has left.' for u in (users = usersExcept user)
      console.log 'user count: ' + users.length
    
    recvMsg: (user, msg) ->
      console.log 'received message, resending to ' + (usersExcept user).length
      u.send {sender: user.name, msg: msg} for u in usersExcept user
