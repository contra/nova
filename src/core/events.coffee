require.register 'events', (module, exports, require) ->
  
  EventEmitter = ->
    @callbacks = {}
    @maxListeners = 10
    
  EventEmitter::listeners = (event) -> @callbacks[event] 
  
  EventEmitter::setMaxListeners = (n) -> @maxListeners = n
    
  EventEmitter::addListener = (event, fn) ->
    throw new Error 'addListener only takes instances of Function' unless typeof fn is 'function'
    @callbacks[event] or= []
    @callbacks[event].push fn
    total = @callbacks[event].length
    if total > @maxListeners > 0
      console.error 'warning: possible EventEmitter memory leak detected. '+total+' listeners added. Use emitter.setMaxListeners() to increase limit.'
    return @   
  
  EventEmitter::on = EventEmitter::addListener  
  
  EventEmitter::once = (event, fn) ->
    fn._emitOnce = true
    @addListener event, fn
    return @
    
  EventEmitter::removeListener = (event, fn) ->
    throw new Error 'addListener only takes instances of Function' unless typeof fn is 'function'
    if @callbacks[event]?
      @callbacks[event] = x for x in @callbacks[event] where x != fn
    return @
    
  EventEmitter::removeAllListeners = (event) ->
    if event?
      if @callbacks[event]?
        delete @callbacks[event]
    else
      @callbacks = {}
    return @ 
      
  EventEmitter::emit = (event, args...) ->
    if @callbacks[event]?
      for fn in @callbacks[event]
        fn.apply fn, args
        if fn._emitOnce
          @callbacks[event].splice _i, 1
          if @callbacks[event].length is 0
            delete @callbacks[event]
            break
    else if event is 'error'
      if !args[0]?
        throw new Error "Uncaught, unspecified 'error' event."
      else if args[0] instanceof Error
        throw args[0]
      else
        throw new Error args[0]
    return @
  
  module.exports.EventEmitter = EventEmitter
