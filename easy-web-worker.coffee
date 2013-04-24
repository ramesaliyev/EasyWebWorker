###
  EasyWebWorker v0.2
  Rames Aliyev -2013

  -> easywebworker.com
###

# EASY-WEB-WORKER CORE

# Abstract Execute Structure for worker controllers.
class _ExecuteStructure

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
        funcName = @context

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
      @context[funcName].apply(@context, args)

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
        funcName = @context

# Browser side web worker controller.
class EasyWebWorker extends _ExecuteStructure

# Create worker, get context and create listeners.
  constructor: (@fileUrl, @callerContext, startupData) ->
    # Assign context as Caller's context.
    @context = @callerContext

    # Create QueryString for startupData
    # If url also has QueryString add data as last value
    if startupData?
      joiner      = if @fileUrl.indexOf("?") isnt -1 then "&" else "?"
      queryString = unless startupData is null then JSON.stringify(startupData) else null
      @fileUrl     += joiner + queryString

    # Create worker.
    # Send EasyWebWorker's context to Webworker fallback.
    @worker = new Worker(@fileUrl, this)

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
    @onerror.apply(@callerContext, arguments) if @onerror instanceof Function

  # Terminate worker.
  terminate: () ->
    # Close worker from browser.
    @worker.terminate()

  # Terminate alias.
  close: () ->
    # Close worker from browser.
    @worker.terminate()

# Worker side web worker controller.
class _WorkerSideController extends _ExecuteStructure

# Get context and create listeners.
  constructor: (@self) ->
    # Assign context as Worker's context.
    @context = @self

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

# FALLBACKS
# Fallback for WorkerSideController
class _WorkerSideFallback extends _WorkerSideController

  constructor: () ->
    # Run WorkerSideController's contruction with artifical location href.
    super({location:{href:easyWebWorkerInstance.fileUrl}})

    # Assign startup data.
    @startupData = @self.startupData

  # Terminate fake worker by assign empty function.
  terminate: () ->
    easyWebWorkerInstance.worker.terminate()

  # Imitate console log.
  log: () ->
    console.log.apply(console, arguments)

  # Post message to EasyWebWorker's listener with fake event in itself context.
  execute: () ->
    easyWebWorkerInstance.listen.call(easyWebWorkerInstance, {worker_fallback:true, data:(arg for arg in arguments)})

# HTML5 Web Worker Fallback.
class _WorkerFallback

# Import Scripts regular expression.
  importscripts_regexp = /importScripts\("(.*)"\);?/gi

  # When worker created load the file.
  # Main: main web worker file.
  # Files: Our filename and content container.
  # Quene: Push jobs to quene before all scripts are loaded.
  # Depth: The depth of importScripts.
  # Worker: Fake worker.
  constructor: (file, @easyWebWorkerInstance, @files={}, @quene=[], @depth=0, @worker=null) ->

    # Avoid create fallback twice.
    window._WorkerPrepared = true

    # Load main script.
    @_loadFile(file, true)

  # Load files with ajax.
  _loadFile: (file, is_main=false) ->
    # Our script container.
    content = null

    # If its not main file, set content as null for mark it as "in progress".
    @files[file].content = null unless is_main

    # Create XHR Object.
    XHR = new XMLHttpRequest() or new ActiveXObject("Msxml2.XMLHTTP") or new ActiveXObject("Microsoft.XMLHTTP")

    # Assign loaded event.
    XHR.onreadystatechange = () =>
      if XHR.readyState is 4 and (XHR.status is 200 or window.location.href.indexOf("http") is -1)

        # Get loaded content.
        content = XHR.responseText

        # Set it as main if its our main worker file.
        if is_main
          @files['main'] = {content: content, depth:0}
          # If its not
        else
          @files[file].content = content

        # Import outer scripts.
        @_importScripts(content)

    # Get the script.
    XHR.open('GET', file, true)
    XHR.send(null)

  # Search for importScripts
  _importScripts: (content) ->
    # Find matches.
    matches = content.match(importscripts_regexp)

    # Push files to load quene.
    if matches?
      # Increase depth
      @depth++

      # Add importScripts into files container to load and process them by right depth order.
      for matched in matches
        @files[matched.replace(importscripts_regexp, "$1")] = {content: undefined, depth:@depth}

    # Load files.
    for filename, data of @files when data.content is undefined and filename isnt "main"
      @_loadFile(filename)

    # Check if all files loaded.
    all_loaded = true
    for filename, data of @files
      all_loaded = false if data.content is undefined or data.content is null

    # If all files are loaded, combine all scripts togehter.
    if all_loaded
      # Handle all depth of imports.
      while @depth--
        # Get parents of depth
        for filename, data of @files when data.depth is @depth
          # Replace importScript() with script itself.
          @files[filename].content = @files[filename].content.replace importscripts_regexp, (to_replace, filename, pos, content) =>
            @files[filename].content

      # Initialize script.
      @_initializeScript(@files.main.content)

  # Run script within wrapper.
  _initializeScript: (script) =>

    # Create IIFE for encapsulation.
    # In private scope run script.
    do () =>
      # Gather runtime variables.
      easyWebWorkerInstance = @easyWebWorkerInstance

      # Eval whole script.
      eval(script)

      # Create WorkerSideController with fallback support.
      self = new _WorkerSideFallback()

      # Assign Worker Fallback's worker to function executer.
      @worker = (command) ->

        # Fake event.
        event = {caller:"WebBrowser", command:command}

        # Analyse command.
        funcName  = command[0]
        args      = command.slice(1)

        # Unshift fake event into args.
        args.unshift(event)

        # Find correct context for worker function.
        # If nested function.
        if funcName.indexOf(".") isnt -1
          funcContext = funcName.split(".")
          funcContext.pop()
          funcContext = funcContext.join(".")
          funcContext = eval(funcContext)

          # If root function.
        else
          funcContext = eval(funcName)

        # Execute.
        eval(funcName).apply(funcContext, args)

    # Run cached commands after initialize completed.
    for command in @quene
      @worker(command)

  # Execute scripts
  postMessage: (command) ->
    # If all script loaded and worker initialized run command.
    if @worker?
      @worker(command)

      # Else add command into command cache
    else
      @quene.push(command)

  # Terminate worker by assign it to empty function.
  terminate: () =>
    @worker = () ->
      null

# STARTUP PROCESS
# Create web worker fallback if browser doesnt support Web Workers.
if this.document isnt undefined and !window.Worker and !window._WorkerPrepared
  window.Worker = _WorkerFallback

# If in a worker run automaticly.
if this.document is undefined

  # Create controller.
  self.caller  = new _WorkerSideController(self)

  # Create function alias.
  self.execute = self.caller.execute
  self.log     = self.caller.log