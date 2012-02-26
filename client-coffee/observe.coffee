plantTimeout  = (ms, cb) -> setTimeout  cb, ms
plantInterval = (ms, cb) -> setInterval cb, ms

API_PREFIX = '/api/0.1'

$ ->
  # Socket
  client =
    sock: io.connect document.domain + API_PREFIX + '/socks/observe'
  
  client.sock.on 'connect', -> console.log 'socket connected'
  client.sock.on 'disconnect', -> console.log 'socket disconnected'
  client.sock.on 'msg', (msg) ->
    console.log 'received message', msg
    processMsg msg
  
  
  # DOM
  $canvas = $ '.observeCanvas'
  canvas = $canvas[0]
  if !canvas then throw "no canvas";
  ctx = canvas?.getContext? '2d'
  if !ctx? then throw 'could not get canvas context'
  
  
  # Draw
  V2D = window.Lace.V2D
  draw = {ctx: ctx, canvas: canvas}
  
  draw.resize = ->
    canvas.width = $canvas.width()
    canvas.height = $canvas.height()
  
  draw.CIRCLE = (x, y, s, blur=0, color='rgba(0, 0, 0, .5)') ->
	  ctx.fillStyle = color
	  ctx.shadowColor = ctx.fillStyle
	  ctx.shadowBlur = blur
	  ctx.beginPath()
	  ctx.arc x, y, s, 0, 2*Math.PI, false
	  ctx.closePath()
	  ctx.fill()
  
  draw.LINE = (a, b, width=3, color='#555') ->
    ctx.lineWidth = width
    ctx.strokeStyle = color
    ctx.beginPath()
    ctx.moveTo a.x, a.y
    ctx.lineTo b.x, b.y
    ctx.stroke()
  
  # Viz
  
  [width, height] = [canvas.width, canvas.height]
  
  users = []
  binds = [] # careful, binds handle this themselves
  getBinds = -> binds = _.reject binds, (b) -> b.age > b.lifetime
  
  class UserBlob
    constructor: (user) ->
      @name = user.name
      @uniq = user.uniq
      @pos = new V2D Math.random() * width, Math.random() * height
      @vel = new V2D 0, 0
    
    update: ->
      @pos.plusEq @vel
      @vel.mulEq 0.95
    
    render: ->
      draw.CIRCLE @pos.x, @pos.y, 10, 10, '#B8D3EE'
  
  class Bind
    constructor: ({@from, @to}) ->
      console.log 'creatd bind from', @from, 'to', @to
      @lifetime = 100
      @age = 0
      binds.push this
    
    update: ->
      ++@age
      if @age < 3
        diff = @to.pos.sub @from.pos
        attract = (diff.div diff.length() + 1).mul 1
        @from.vel.plusEq attract
        @to.vel.subEq  attract
    
    render: ->
      alpha = 1-(@age/@lifetime)
      draw.LINE @from.pos, @to.pos, 3, 'rgba(255, 8, 0, '+alpha+')'
  
  processMsg = (msg) ->
    safeUseUser = (user) ->
      u = (_.detect users, (u) -> u.uniq is user.uniq)
      if u? then u else initUser(user)
    vizMsg
      from: safeUseUser msg.from
      to:   safeUseUser msg.to
      msg:  msg.msg
  
  initUser = (user) ->
    u = new UserBlob user
    console.log 'users is now of length', users.push u
    u
  
  vizMsg = (msg) ->
    console.log 'visualizing message from', msg.from, 'to', msg.to, 'of length', msg.msg.length
    new Bind msg
  
  (frameLoop = ->
    draw.resize()
    (b.update(); b.render()) for b in getBinds()
    (u.update(); u.render()) for u in users
    plantTimeout 15, frameLoop
  )()