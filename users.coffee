# This is what a user has:
# name
# uniq     -- something serializable and unique to use as a basis for comparison
# sendMsg  -- a way to send messages to them
# sendList -- a way to send an updated user list down

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
      u.sendList {users: users, delta: {state: 'joined', user: user}} for u in users
      user
    
    leave: (user) ->
      console.log user.name + ' has left.'
      users = usersExcept user
      u.sendList {users: users, delta: {state: 'left', user: user}} for u in users
      console.log 'user count: ' + users.length
    
    recvMsg: (user, msg) ->
      console.log 'received message from ' + user.name +
                  ', resending to ' + (usersExcept user).length
      msg.sender = user
      u.sendMsg msg for u in usersExcept user
