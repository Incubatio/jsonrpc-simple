define (require) ->

  ###
    JSON-RPC 2.0, specification taken from http://www.jsonrpc.org/specification
    @author incubatio <work@incubatio.org>
  ###
  class JSONRPC

    @DEBUG: true

    @VERSION: "2.0"

    @INVALID_REQUEST  : -32600
    @METHOD_NOT_FOUND : -32601
    @INVALID_PARAMS   : -32602
    @INTERNAL_ERROR   : -32603
    @PARSE_ERROR      : -32700
    #@SERVER_ERROR    : -32000 to -32099

    errorMsgs = {}
    errorMsgs[JSONRPC.INVALID_REQUEST]   = "Invalid Request"
    errorMsgs[JSONRPC.METHOD_NOT_FOUND]  = "Method not found"
    errorMsgs[JSONRPC.INVALID_PARAMS]    = "Invalid params"
    errorMsgs[JSONRPC.INTERNAL_ERROR]    = "Internal error"
    errorMsgs[JSONRPC.PARSE_ERROR]       = "Parse error"

    ###
    (specification quote:) A rpc call is represented by sending a Request object to a Server.
      @param string jsonrpc       - MUST be exactly "2.0".
      @param string method        - contains name of the method to be invoked.
      @param Array|Object params  - holds the parameter values to be used during method invocation. MAY be omitted.
      @param int|string|null id   - identifier established by Client. If id not included, req assumed as notification.
      @return Boolean
    ###
    @isValidRequest: (req) ->
      req.id = req.id || null
      req.params = req.params || null
      #console.log 21, req, req.jsonrpc == JSONRPC.VERSION
      #console.log 22, req.params == "object" || req.params == null
      #console.log 23, typeof req.id == "number" || typeof req.id == "string" || req.id == null

      return req.jsonrpc == JSONRPC.VERSION &&
        typeof req.method == "string" &&
        ( typeof req.params == "object" || req.params == null) &&
        ( typeof req.id == "number" || typeof req.id == "string" || req.id == null)



    ###
    HandleRequest takes raw JSON, parse it, check if it's a batch of request and process it.
      @param string req      - unparsed JSON
      @param Array services  - keys are method name, value are functions
      @return Object | Array
    ###
    @handleRequest: (req, services) ->

      res = []
      batch = []
      isBatch = false

      # Parse JSON
      try
        batch = if typeof req == "string" then JSON.parse(req) else req
        if Array.isArray(batch) && batch.length > 0 then isBatch = true else batch = [batch]
      catch e
        if JSONRPC.DEBUG then console.log "[DEBUG]", e
        errorCode = JSONRPC.PARSE_ERROR
        res = [{ jsonrpc: "2.0", error: { code: errorCode, message: errorMsgs[errorCode] }}]
        res[0].id  = req.id || null

      # If notification, no result awaited, execture it async
      for req in batch
        #res.push JSONRPC._handleRequest(req, services)
        buff = JSONRPC._handleRequest(req, services)
        if(req.id || buff.error) then res.push buff
    
      return if res.length > 0
        if isBatch then res else res[0]
      else null

  


    ###
    Check if valid request, check if method exists in services, check if valid parameter, then try to run the service.
      @param Object req
      @param Array services
      @return Object - JSON-RPC 2.0 response.
    ###
    @_handleRequest: (req, services) ->
      errorCode = false

      if(JSONRPC.isValidRequest(req))
        if(services && typeof services[req.method] == "function")
          if typeof req.params == "object" || req.params == null
            if !Array.isArray(req.params) then req.params = [req.params]
            try
              result = services[req.method].apply(this, req.params)
            catch e
              if JSONRPC.DEBUG then console.log "[DEBUG]", e
              errorCode = JSONRPC.INTERNAL_ERROR
          else
            errorCode = JSONRPC.INVALID_PARAMS
        else
          errorCode = JSONRPC.METHOD_NOT_FOUND
      else
        errorCode = JSONRPC.INVALID_REQUEST

      return if errorCode
        res = { jsonrpc: "2.0", error: { code: errorCode, message: errorMsgs[errorCode] }}
        res.id  = req.id || null
        res
      else
        { jsonrpc: "2.0", result: result, id: req.id }
