## Store: Socket

Fluxxor = require 'fluxxor'

module.exports = (app) ->

  socket = app.socket

  Fluxxor.createStore

    initialize: ->
      @status = 'unknown'
      @bindActions 'set-socket-status', @setStatus

    getState: ->
      status: @status

    setStatus: (@status) -> @emit 'change'
