=======
jsonrpc
=======

Support for json rpc 2.0 based on http://www.jsonrpc.org/specification.

Install
=======

``npm install jsonrpc-simple``


Example
=======

.. code:: coffeescript

  req = '{"jsonrpc": "2.0", "method": "sum", "params": [1, 2, 4], "id": 1}'

  services =
    sum: (a, args...) ->
      for i in args then a += i
      return a

  res = JSONRPC.handleRequest(req, services)

  console.log res
  # displays {"jsonrpc": "2.0", "result": 7, "id": "1"}

