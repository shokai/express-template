React   = require 'react'
Fluxxor = require 'fluxxor'
socket  = require('socket.io-client').connect "#{location.protocol}//#{location.host}"

app =
  socket: socket
  pkg: require '../../package.json'

##  flux = stores, actions
app.flux = new Fluxxor.Flux
  Chat:   new (require('./stores/chat')(app))
  Socket: new (require('./stores/socket')(app))
, require('./actions/actions')(app)

require('./sockets/chat')(app)

View = require './views/main'

React.render <View flux={app.flux} />
, document.getElementById 'app-container'
