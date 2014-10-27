socket = io.connect "#{location.protocol}//#{location.host}"

socket.on 'connect', ->
  console.log 'socket.io connect!!'


## backbone/marionette ##
window.App = new Backbone.Marionette.Application
App.addRegions
  inputRegion: '#input-region'
  logsRegion:  '#logs-region'

App.addInitializer (opts) ->
  console.log 'app start'
  @logs = new Logs chatLogs
  @logsView = new LogsView collection: @logs
  App.logsRegion.show @logsView
  App.inputRegion.show new InputView

  ## send ##
  App.on 'input:send', (message) ->
    for key in ['body', 'from']
      return if message.get(key)?.trim().length < 1
    socket.emit 'message', message.attributes

  ## receive ##
  socket.on 'message', (data) ->
    App.logs.add data

  ## delete ##
  App.on 'message:delete', (message) ->
    socket.emit 'message:delete', message.get '_id'

  socket.on 'message:delete', (_id) ->
    return unless message = App.logs.findWhere _id: _id
    App.logs.remove message

  ## edit ##
  App.on 'message:edit', (message) ->
    if message.get('body').length < 1
      return App.trigger 'message:delete', message
    socket.emit 'message:edit', message.attributes

  socket.on 'message:edit', (data) ->
    return unless data._id?
    return unless message = App.logs.findWhere _id: data._id
    message.set 'body', data.body


## models/views ##
Message = Backbone.Model.extend
  defaults: ->
    body: null
    from: null
    created_at: Date.now()-0
    _id: null
  idAttribute: '_id'

MessageView = Backbone.Marionette.ItemView.extend
  tagName:  'li'
  className:'message'
  getTemplate: ->
    if @model.get 'isEdit'
      '#message-template-edit'
    else
      '#message-template'
  events:
    'click .delete': ->
      App.trigger 'message:delete', @model
    'mouseover': ->
      @.$('.delete').show()
    'mouseout': ->
      @.$('.delete').hide()
    'click .noedit': ->
      @model.set 'isEdit', true
      @.$('input').focus()
    'keydown .edit input': (e) ->
      if e.keyCode is 13
        App.trigger 'message:edit', @model
        @model.set 'isEdit', false
  modelEvents: ->
    'change:isEdit': ->
      @render()
  bindings:
    '.edit input': 'body'
    '.from': 'from'
    '.body': 'body'
  onRender: ->
    @.$('.delete').hide()
    @.$el.hide().fadeIn 300
    @stickit()
  destroy: ->
    @.$el.fadeOut 500, =>
      Backbone.Marionette.ItemView.prototype.destroy.apply this, arguments


Logs = Backbone.Collection.extend
  model: Message
  comparator: (i) ->
    i.attributes.created_at * -1

LogsView = Backbone.Marionette.CompositeView.extend
  template: '#logs-template'
  tagName:  'div'
  id: 'logs-view'
  childView: MessageView
  childViewContainer: 'ul'

InputView = Backbone.Marionette.ItemView.extend
  template: '#input-template'
  tagName:  'div'
  id: 'input-view'
  model: new Message
    body: 'hello!'
    from: 'NoName'
  events:
    'click .send': 'send'
    'keydown .body': (e) ->
      if e.keyCode is 13
        @send()
  bindings:
    '.from': 'from'
    '.body': 'body'
  send: ->
    App.trigger 'input:send', @model
    @model.set 'body', ''
  onRender: ->
    @stickit()

$ ->
  console.log 'start'
  App.start()
