# This is what a user has:
# name
# uniq     -- something serializable and unique to use as a basis for comparison
# sendMsg  -- a way to send messages to them
# sendList -- a way to send an updated user list down

_U = require 'underscore'

users = []
usersExcept = (user) -> _U.without users, user
observers = []

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
    
    passMsg: (msg) ->
      # console.log 'received message from ' + msg.from.name +
      #             ', resending to ' + (usersExcept user).length
      recipient = (_U.detect users, (u) -> msg.to.uniq is u.uniq)
      if recipient?
        recipient.sendMsg msg
        o.sendMsg msg for o in observers
      else
        msg.from.sendList {users: users}
        throw 'tried to passage message to disappeared user'
  
  app.observers =
    join: (o) ->
      observers.push o
    leave: (o) ->
      observers = _.without observers, o
