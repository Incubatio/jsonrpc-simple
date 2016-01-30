###
# Syntax:
#  req: --> data sent to Server
#  res: <-- data sent to Client
#
# Tests based on http://www.jsonrpc.org/specification - 7.Examples
#
###
module.exports = [
  "rpc call with positional parameters"
  {
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 1}'
  }, {
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}'
    res: '{"jsonrpc": "2.0", "result": -19, "id": 2}'
  },

  "rpc call with named parameters"
  {
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 3}'
  }, {
    req: '{"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 4}'
    res: '{"jsonrpc": "2.0", "result": 19, "id": 4}'
  },

  "a notification (rpc call without id that doesn't expect any response)"
  {
    req: '{"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}'
  }, {
    req: '{"jsonrpc": "2.0", "method": "foobar"}'
  },

  "rpc call with non-existent method"
  {
    req: '{"jsonrpc": "2.0", "method": "foobar2", "id": "1"}'
    res: '{"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"}'
  },

  "rpc call with invalid JSON"
  {
    req: '{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}'
  },

  "rpc call call with invalid Request object"
  {
    req: '{"jsonrpc": "2.0", "method": 1, "params": "bar"}'
    res: '{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}'
  },

  "rpc call call Batch, invalid JSON"
  {
    req: '[
      {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
      {"jsonrpc": "2.0", "method"
    ]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}'
  },

  "rpc call with an empty Array (or empty Batch)"
  {
    req: '[]'
    res: '{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}'
  },

  "rpc call with an invalid Batch (but not empty)"
  {
    req: '[1]'
    res: '[
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    ]'
  },

  "rpc call with invalid Batch"
  {
    req: '[1,2,3]'
    res: '[
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
      {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
    ]'
  },

  "rpc call with valid Batch"
  {
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
            {"jsonrpc": "2.0", "result": ["hellonull", 5], "id": "9"}
        ]'
  },


  "rpc call Notification Batch"
  {
    req: '[
            {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
            {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
        ]'
  }
  #Nothing is returned for all notification batches
]
