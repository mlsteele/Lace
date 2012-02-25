var DEBUG = true;

require('coffee-script');
require('./util/compile-coffee')(__dirname+'/client-coffee', __dirname+'/public/js');
require('./util/timers');
var express = require('express');

var app = module.exports = express.createServer();

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

app.API_PREFIX = '/api/0.1'
require('./users')(app);
require('./routes/main')(app);
require('./routes/socket')(app);

if (!module.parent) {
  app.listen(3000);
  console.log("Express server listening on port %d", app.address().port);
}
