###
Syntax:

req: data sent to Server
res: data sent to Client
###

tests = [
  # rpc call with positional parameters:
  {
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 1}'
  }, {

    req: '{"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}'
    res: '{"jsonrpc": "2.0", "result": -19, "id": 2}'
  }, {

  # rpc call with named parameters:
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 3}'
  }, {

    req: '{"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 4}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 4}'
  }, {

  # a Notification:
    req: '{"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}'
  }, {
    req: '{"jsonrpc": "2.0", "method": "foobar"}'
  }, {

  # rpc call of non-existent method:
    req: '{"jsonrpc": "2.0", "method": "foobar2", "id": "1"}'
    res: '{"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"}'
  }, {

  # rpc call with invalid JSON:
    req: '{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}'
  }, {

  # rpc call with invalid Request object:
    req: '{"jsonrpc": "2.0", "method": 1, "params": "bar"}'
    res: '{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}'
  }, {

  # rpc call Batch, invalid JSON:
    req: '[
      {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
      {"jsonrpc": "2.0", "method"
    ]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}'
  }, {

  # rpc call with an empty Array:
    req: '[]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}'
  }, {

  # rpc call with an invalid Batch (but not empty):
    req: '[1]'
    res: '[
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    ]'
  }, {

  # rpc call with invalid Batch:
    req: '[1,2,3]'
    res: '[
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    ]'
  }, {

  # rpc call Batch:
    req: '[
            {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
            {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
            {"jsonrpc": "2.0", "method": "subtract", "params": [42,23], "id": "2"},
            {"foo": "boo"},
            {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
            {"jsonrpc": "2.0", "method": "get_data", "id": "9"}
        ]'
    res: '[
            {"jsonrpc": "2.0", "result": 7, "id": "1"},
            {"jsonrpc": "2.0", "result": 19, "id": "2"},
            {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
            {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "5"},
            {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
        ]'
  }, {

  # rpc call Batch (all notifications):
    req: '[
            {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
            {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
        ]'
  }
  #Nothing is returned for all notification batches
]
JSONRPC = null
global.define = (cb) ->
  JSONRPC = cb()

require('../build/jsonrpc')

services =
  sum: (a, args...) ->
    for i in args then a += i
    a
  subtract: (a, args...) ->
    if typeof a == "object"
      a.minuend - a.subtrahend
    else
      for i in args then a -= i
      a
  notify_hello: (a) ->
    #console.log "hello " + a
  notify_sum: (a, args...) ->
    for i in args then a += i
    #console.log "sum:", a
  update: (a) ->
    #console.log "update notification", a
  foobar: () ->
    #console.log "foobar notification"
  get_data: (a) ->
    return ["hello", 5]

for test in tests
  console.log "TEST >>> ", test.req
  res = JSONRPC.handleRequest(test.req, services)
  res = if res then JSON.stringify(res) else ""
  test.res = test.res || ""


  if(res.replace(/\ /g, "") != test.res.replace(/\ /g, ""))
    console.log "Fail <<<<< "
    console.log "    1. ", res.replace(/\ /g, "")
    console.log "    2. ", test.res.replace(/\ /g, "")
  else
    console.log "Pass <<<<< "
  console.log ""
