mongoose = require 'mongoose'

module.exports = (app) ->

  messageSchema = new mongoose.Schema
    from:
      type: String
      validate: [
        (v) ->
          v.trim().length > 0
        'invalid "from"'
      ]
    body:
      type: String
      validate: [
        (v) ->
          v.trim().length > 0
        'invalid "body"'
      ]
    created_at:
      type: Date
      default: Date.now

  messageSchema.statics.latest = (num, callback) ->
    return @find {}
    .sort
      created_at: 'desc'
    .limit num
    .exec callback

  messageSchema.methods.to_hash = ->
    from: @from
    body: @body
    created_at: @created_at-0
    _id: @_id

  mongoose.model 'Message', messageSchema
