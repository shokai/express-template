debug    = require('debug')('chat:sockets')
mongoose = require 'mongoose'

Message = mongoose.model 'Message'

module.exports = (app) ->
  io = app.get 'socket.io'

  io.on 'connection', (socket) ->
    debug 'new connection'

    socket.on 'message', (data) ->
      debug data
      message = new Message from: data.from, body: data.body
      message.save (err) ->
        return debug err if err
        io.sockets.emit 'message', message.to_hash()  # broadcast

    socket.on 'message:edit', (data) ->
      return unless data._id?
      debug "edit #{JSON.stringify data}"
      Message.findById data._id, (err, message) ->
        return debug err if err
        message.update {body: data.body}, (err) ->
          return debug err if err
          message.body = data.body
          io.sockets.emit 'message:edit', message.to_hash()

    socket.on 'message:delete', (_id) ->
      debug "message:delete #{_id}"
      Message.remove {_id: _id}, (err) ->
        if err
          return debug err
        io.sockets.emit 'message:delete', _id

    io.sockets.emit 'message',
      from: "server"
      body: "hello new client (id:#{socket.id})"
