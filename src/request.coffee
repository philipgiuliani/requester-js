class @Request
  Helpers.includeInto(this)

  DEFAULTS =
    url: null
    method: "GET"
    format: "json"
    async: true
    data: null

  # @POST = (options = {}) ->
  #   options.method = "POST"
  #   new Request(options)

  constructor: (options = {}) ->
    @_emitter = new Emitter
    @xhr = new XMLHttpRequest

    events = ["before", "success", "error", "complete"]
    for event in events
      if typeof options[event] is "function"
        @_emitter.on event, options[event]
        delete options[event]

    @merge this, DEFAULTS
    @merge this, options

  send: ->
    @xhr.open(@method, @url, @async, @username, @password)
    @_setRequestHeaders()

    @_emitter.emit "before", @xhr

    @xhr.addEventListener "readystatechange", @_handleStateChange.bind(this)
    @xhr.send @_requestData()

  response: ->
    return false unless @xhr.readyState is XMLHttpRequest.DONE

    try
      JSON.parse(@xhr.responseText)
    catch
      @xhr.responseText

  on: (args...) -> @_emitter.on args...

  off: (args...) -> @_emitter.off args...

  _setRequestHeaders: ->
    # TODO: DRY it up (_requestData has the same)
    if @data && @data.constructor is Object
      @xhr.setRequestHeader "Content-Type", "application/json;charset=UTF-8"

  _handleStateChange: ->
    return unless @xhr.readyState is XMLHttpRequest.DONE

    if @xhr.status in [200..299]
      @_requestSuccess()
    else
      @_requestError()

    @_emitter.emit "complete", @xhr, @xhr.status

  _requestSuccess: ->
    @_emitter.emit "success", @response, @xhr.status, @xhr

  _requestError: ->
    @_emitter.emit "error", @xhr, @xhr.status

  _requestData: ->
    if @data && @data.constructor is Object
      return JSON.stringify(@data)

    @data
