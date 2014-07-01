'use strict'

path     = require 'path'
debug    = require('debug')('chat:app')
express  = require 'express'
mongoose = require 'mongoose'

## config ##
config       = require path.resolve 'config.json'
package_json = require path.resolve 'package.json'
process.env.PORT ||= 3000


## express modules
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'

## server setup ##
module.exports = app = express()
app.disable 'x-powered-by'
app.set 'view engine', 'jade'
app.use express.static path.resolve 'public'
app.use cookieParser()
app.use bodyParser()

http = require('http').Server(app)
io = require('socket.io')(http)
app.set 'socket.io', io
app.set 'config', config
app.set 'package', package_json


## MongoDB ##
mongodb_uri = process.env.MONGOLAB_URI or
              process.env.MONGOHQ_URL or
              'mongodb://localhost/express-template'

mongoose.connect mongodb_uri, (err) ->
  if err
    console.error "mongoose connect failed"
    console.error err
    process.exit 1
    return

  debug "connect MongoDB"

  ## load controllers, models, socket.io ##
  components =
    models:      [ 'message' ]
    controllers: [ 'main' ]
    sockets:     [ 'chat' ]

  for type, items of components
    for item in items
      debug "load #{type}/#{item}"
      require(path.resolve type, item)(app)


  if process.argv[1] isnt __filename
    return   # if load as a module, do not start HTTP server

  ## start server ##
  http.listen process.env.PORT, ->
    debug "server start - port:#{process.env.PORT}"
