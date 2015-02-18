class @RequestJob
  constructor: (request, priority=RequestQueue.NORMAL) ->
    @request = request
    @priority = priority

  run: (complete) ->
    @request.on "complete", complete.bind(this)
    @request.async = true
    @request.send()