# Browser side web worker controller.
class EasyWebWorker
  constructor: (fileUrl, @self) ->
    # Create worker.
    @worker = new Worker(fileUrl)

    # Listen for messages.
    @worker.onmessage = () =>
      @listen.apply(@, arguments)

  execute: () ->
    # Copy arguments to avoid "DataCloneError: The object could not be cloned."
    args = (arg for arg in arguments)

    # Pass arguments to web worker.
    @worker.postMessage(args)

  listen: (event) ->
    # Separate funcName and arguments.
    args = event.data

    funcName = args[0]
    args = args.slice(1)
    args.unshift(event)

    # Call func with arguments.

    # If func is nested
    if funcName.indexOf(".") is -1
      @self[funcName].apply(@self, args)

    # If not
    else
      nestedFunc = funcName.split(".")
      funcName = @self
      deep = nestedFunc.length
      context = ""

      for func, order in nestedFunc
        funcName = funcName[func]

        # Correct context.
        if order is deep - 2
          context = funcName

      funcName.apply(context, args)

# Worker side web worker controller.
class WorkerSideController
  constructor: (@self) ->
    # Listen for messages.
    @self.onmessage = () =>
      @listen.apply(@, arguments)

  execute: () ->
    # Copy arguments to avoid "DataCloneError: The object could not be cloned."
    args = (arg for arg in arguments)

    # Pass arguments to web worker.
    @self.postMessage(args)

  listen: (event) ->
    # Separate funcName and arguments.
    args = event.data

    funcName = args[0]
    args = args.slice(1)
    args.unshift(event)

    # Call func with arguments.
    @self[funcName].apply(@self, args)

# If in a worker, run automaticly.
if this.document is undefined
  this.caller = new WorkerSideController(@)
  this.execute = this.caller.execute