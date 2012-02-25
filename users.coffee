# This is what a user has:
# name
# send -- a way to send messages to them

_U = require 'underscore'

users = []
usersExcept = (user) -> _U.without users, user

module.exports = (app) ->
  app.users =
    join: (user) ->
      if (_U.detect users, (u) -> u is user)?
        throw 'cannot register user who is already in users (' + user.name + ')'
      users.push user
      console.log 'joined user named ' + user.name
      console.log 'user count: ' + users.length
      user
    
    leave: (user) ->
      console.log user.name + ' has left.'
      u.send {msg: user.name + ' has left.'} for u in (users = usersExcept user)
      console.log 'user count: ' + users.length
    
    recvMsg: (user, msg) ->
      console.log 'received message from ' + user.name +
                  ', resending to ' + (usersExcept user).length
      msg.sender = user.name
      u.send msg for u in usersExcept user
