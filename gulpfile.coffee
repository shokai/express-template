'use strict';

stream = require 'stream'
ws = stream.Writable()
ws._write = (chunk, enc, next) ->
  console.log chunk.length
  console.log chunk.toString()
  next()
ws.on 'finish', ->
  console.log 'ws finish'



gulp = require 'gulp'
util = require 'gulp-util'

browserify = require 'browserify'

source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
watchify = require 'watchify'
sourcemaps = require 'gulp-sourcemaps'


onError = (err) ->
  util.log util.colors.red('ERROR'), err.message
  @end()

gulp.task 'build', ->
  gulp.src './client/js/**.{coffee,cjsx}'
  .pipe browserify({
      debug: true
      transform: ['coffee-reactify']
      extensions: ['.coffee', '.cjsx']
    })
  .pipe ws
  # .pipe gulp.dest './public/js'

gulp.task 'tmp', ->

  gulp.src './client.js/**.{coffee,cjsx}'
  .pipe ws

