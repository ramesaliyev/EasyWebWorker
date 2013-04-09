# Abstract Structure for EasyWebWorker
class AbstractEasyWebWorker

  # Execute function.
  execute: (args) ->
    # Copy arguments to avoid "DataCloneError: The object could not be cloned."
    (arg for arg in args)

  # Listen for communication.
  listen: (event) ->

    # Separate funcName and arguments.
    args      = event.data
    funcName  = args[0]
    args      = args.slice(1)

    # Add event as first argument.
    args.unshift(event)

    # If function name contains . (dot) process it as nested function.
    if funcName.indexOf(".") isnt -1

      # Split name.
      nestedFunc   = funcName.split(".")

      # Check if target function is assigned to window and script running on browser.
      if nestedFunc[0] is "window" and event.caller is "WebWorker"
        funcName    = window
        nestedFunc  = nestedFunc.slice(1)
      else
        funcName = @self

      # Get nesting depth.
      depth = nestedFunc.length

      # Reach function.
      for func, order in nestedFunc
        funcName = funcName[func]

        # Correct context.
        context = funcName if order is depth - 2

      # Execute nested function with correct context.
      funcName.apply(context, args)

    else
      # If function is single, direct execute it.
      @self[funcName].apply(@self, args)

  # Get value of variable.
  get: (variable, callback, from) ->

    # If variable name contains . (dot) process it as nested object.
    if funcName.indexOf(".") isnt -1

      # Split name.
      nestedFunc   = funcName.split(".")

      # Check if target function is assigned to window and script running on browser.
      if nestedFunc[0] is "window" and event.caller is "WebWorker"
        funcName    = window
        nestedFunc  = nestedFunc.slice(1)
      else
        funcName = @self




# Browser side web worker controller.
class EasyWebWorker extends AbstractEasyWebWorker

  # Create worker, get context and create listeners.
  constructor: (fileUrl, @self, startupData) ->
    # Create QueryString for startupData
    # If url also has QueryString add data as last value

    if startupData?
      joiner      = if fileUrl.indexOf("?") isnt -1 then "&" else "?"
      queryString = unless startupData is null then JSON.stringify(startupData) else null
      fileUrl += joiner + queryString

    # Create worker.
    @worker = new Worker(fileUrl)

    # Listen for messages.
    @worker.onmessage = () =>
      @listen.apply(@, arguments)

    # Error statement.
    @worker.onerror = (event) =>
      @error.call(@, event, event.filename, event.lineno, event.message)

  # Add special tag on listen event
  listen: (event) ->
    event.caller = "WebWorker"
    super(event)

  # Execute worker function.
  execute: () ->
    # Pass arguments to web worker.
    @worker.postMessage(super(arguments))

  # Error statement.
  error: () ->
    # Execute onError function if assigned.
    @onerror.apply(@self, arguments) if @onerror instanceof Function

  # Terminate worker.
  terminate: () ->
    # Close worker from browser.
    @worker.terminate()

  # Terminate alias.
  close: () ->
    # Close worker from browser.
    @worker.terminate()

# Worker side web worker controller.
class WorkerSideController extends AbstractEasyWebWorker

  # Get context and create listeners.
  constructor: (@self) ->
    # Get startup data from href and convert it to js object.
    locationHref  = @self.location.href

    # Check the joiner
    if locationHref.indexOf("&") isnt -1
      splitBy = "&"
    else if locationHref.indexOf("?") isnt -1
      splitBy = "?"
    else
      splitBy = false

    # If href has starupData
    if splitBy isnt false
      startupData   = locationHref.split(splitBy)
      startupData   = startupData[startupData.length-1]

    # If startupData exist
    if startupData isnt null and startupData isnt undefined
      @self.startupData = JSON.parse(decodeURIComponent(startupData))
    else
      @self.startupData = null

    # Listen for messages.
    @self.onmessage = () =>
      @listen.apply(@, arguments)

  # Add special tag on listen event
  listen: (event) ->
    event.caller = "WebBrowser"
    super(event)

  # Execute browser function.
  execute: () ->
    # Pass arguments to web worker.
    @self.postMessage(super(arguments))

  # Call window.console.log function
  log: () ->
    @self.execute("window.console.log", arguments)

# If in a worker, run automaticly.
if this.document is undefined

  # Create controller.
  this.caller  = new WorkerSideController(@)

  # Create function alias.
  this.execute = this.caller.execute
  this.log     = this.caller.log