# From: https://gist.github.com/rpflorence/3734609

Emitter =
  _callbacks: []

  on: (event, fn) ->
    @_callbacks[event] or= []
    @_callbacks[event].push fn
    this

  once: (event, fn) ->
    once = =>
      @off event, once
      fn.apply this, arguments
    fn._off = once
    @on event, once

  off: (event, fn) ->
    callbacks = @_callbacks[event]
    return this unless callbacks

    # remove all handlers
    if 1 is arguments.length
      delete @_callbacks[event]
      return this

    # remove specific handler
    i = callbacks.indexOf(fn._off or fn)
    callbacks.splice i, 1 if ~i
    this

  emit: (event, args...) ->
    callbacks = @_callbacks[event]
    if callbacks
      for callback in callbacks.slice 0
        callback.apply(this, args)
    this