_U = require 'underscore'

users = []

module.exports = (app) ->
  app.user = {
    login: (userName) ->
      console.log 'logging in user named "' + userName + '"'
      user = _U.detect users, ((e) -> e.name is userName)
      if user? then console.log 'who already exists'; return user
      user = {
        name: userName
        created: new Date().toJSON()}
      console.log 'created new user', user.name
      users.push user
      user
    
    say: (user, msg) ->
      console.log user.name, 'said', msg
      'ok'
  }
  
  # plantInterval 2000, -> console.log 'users:', users
