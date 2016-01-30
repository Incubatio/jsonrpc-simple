JSONRPC = require('../../lib/jsonrpc')

# include tests
tests = require('./tests')

log = (args...) ->
  #console.log args.join(" ")

# define a simple service
services =
  sum: (a, args...) ->
    for i in args then a += i
    return a

  subtract: (a, args...) ->
    if typeof a == "object"
      return a.minuend - a.subtrahend
    else
      for i in args then a -= i
      return a

  notify_hello: (a) ->
    log "hello " + a

  notify_sum: (a, args...) ->
    for i in args then a += i
    log "sum:", a

  update: (a) ->
    log "update notification", a

  foobar: () ->
    log "foobar notification"

  get_data: () ->
    return ["hello", 5]

console.log "\n"
console.log '  JSON-RPC test suite'
lines = []
fails = []
name = null
for test in tests
  if typeof test == 'string'

    if name then lines.unshift "    " + (if lines.length > 1 then "X" else "✓") + " " + name
    if lines.length > 0 then console.log lines.join("\n")
    name = test
    lines = []
  else
    try
      res = JSONRPC.handleRequest(test.req, services)
    catch e
      if e instanceof Error
        console.log e
        process.exit(1)
      else
        console.log e

    res = if res then JSON.stringify(res) else ""
    test.res = test.res || ""


    if(res.replace(/\ /g, "") != test.res.replace(/\ /g, ""))
      lines.push "      On " + test.req
      lines.push "      1. Expected: " + test.res.replace(/\ /g, "")
      lines.push "      2. Got:      " + res.replace(/\ /g, "")
      lines.push ""
