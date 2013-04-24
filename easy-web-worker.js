// Generated by CoffeeScript 1.6.2
/*
  EasyWebWorker v0.4
  Rames Aliyev -2013

  -> easywebworker.com
*/

var EasyWebWorker, _ExecuteStructure, _WorkerFallback, _WorkerSideController, _WorkerSideFallback,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ExecuteStructure = (function() {
  function _ExecuteStructure() {}

  _ExecuteStructure.prototype.execute = function(args) {
    var arg, _i, _len, _results;

    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      _results.push(arg);
    }
    return _results;
  };

  _ExecuteStructure.prototype.listen = function(event) {
    var args, context, depth, func, funcName, nestedFunc, order, _i, _len;

    args = event.data;
    funcName = args[0];
    args = args.slice(1);
    args.unshift(event);
    if (funcName.indexOf(".") !== -1) {
      nestedFunc = funcName.split(".");
      if (nestedFunc[0] === "window" && event.caller === "WebWorker") {
        funcName = window;
        nestedFunc = nestedFunc.slice(1);
      } else {
        funcName = this.context;
      }
      depth = nestedFunc.length;
      for (order = _i = 0, _len = nestedFunc.length; _i < _len; order = ++_i) {
        func = nestedFunc[order];
        funcName = funcName[func];
        if (order === depth - 2) {
          context = funcName;
        }
      }
      return funcName.apply(context, args);
    } else {
      return this.context[funcName].apply(this.context, args);
    }
  };

  _ExecuteStructure.prototype.get = function(variable, callback, from) {
    var funcName, nestedFunc;

    if (funcName.indexOf(".") !== -1) {
      nestedFunc = funcName.split(".");
      if (nestedFunc[0] === "window" && event.caller === "WebWorker") {
        funcName = window;
        return nestedFunc = nestedFunc.slice(1);
      } else {
        return funcName = this.context;
      }
    }
  };

  return _ExecuteStructure;

})();

EasyWebWorker = (function(_super) {
  __extends(EasyWebWorker, _super);

  function EasyWebWorker(fileUrl, callerContext, startupData) {
    var joiner, queryString,
      _this = this;

    this.fileUrl = fileUrl;
    this.callerContext = callerContext;
    this.context = this.callerContext;
    if (startupData != null) {
      joiner = this.fileUrl.indexOf("?") !== -1 ? "&" : "?";
      queryString = startupData !== null ? JSON.stringify(startupData) : null;
      this.fileUrl += joiner + queryString;
    }
    this.worker = new Worker(this.fileUrl, this);
    this.worker.onmessage = function() {
      return _this.listen.apply(_this, arguments);
    };
    this.worker.onerror = function(event) {
      return _this.error.call(_this, event, event.filename, event.lineno, event.message);
    };
  }

  EasyWebWorker.prototype.listen = function(event) {
    event.caller = "WebWorker";
    return EasyWebWorker.__super__.listen.call(this, event);
  };

  EasyWebWorker.prototype.execute = function() {
    return this.worker.postMessage(EasyWebWorker.__super__.execute.call(this, arguments));
  };

  EasyWebWorker.prototype.error = function() {
    if (this.onerror instanceof Function) {
      return this.onerror.apply(this.callerContext, arguments);
    }
  };

  EasyWebWorker.prototype.terminate = function() {
    return this.worker.terminate();
  };

  EasyWebWorker.prototype.close = function() {
    return this.worker.terminate();
  };

  return EasyWebWorker;

})(_ExecuteStructure);

_WorkerSideController = (function(_super) {
  __extends(_WorkerSideController, _super);

  function _WorkerSideController(self) {
    var locationHref, splitBy, startupData,
      _this = this;

    this.self = self;
    this.context = this.self;
    locationHref = this.self.location.href;
    if (locationHref.indexOf("&") !== -1) {
      splitBy = "&";
    } else if (locationHref.indexOf("?") !== -1) {
      splitBy = "?";
    } else {
      splitBy = false;
    }
    if (splitBy !== false) {
      startupData = locationHref.split(splitBy);
      startupData = startupData[startupData.length - 1];
    }
    if (startupData !== null && startupData !== void 0) {
      this.self.startupData = JSON.parse(decodeURIComponent(startupData));
    } else {
      this.self.startupData = null;
    }
    this.self.onmessage = function() {
      return _this.listen.apply(_this, arguments);
    };
  }

  _WorkerSideController.prototype.listen = function(event) {
    event.caller = "WebBrowser";
    return _WorkerSideController.__super__.listen.call(this, event);
  };

  _WorkerSideController.prototype.execute = function() {
    return this.self.postMessage(_WorkerSideController.__super__.execute.call(this, arguments));
  };

  _WorkerSideController.prototype.log = function() {
    return this.self.execute("window.console.log", arguments);
  };

  return _WorkerSideController;

})(_ExecuteStructure);

_WorkerSideFallback = (function(_super) {
  __extends(_WorkerSideFallback, _super);

  function _WorkerSideFallback() {
    _WorkerSideFallback.__super__.constructor.call(this, {
      location: {
        href: easyWebWorkerInstance.fileUrl
      }
    });
    this.startupData = this.self.startupData;
  }

  _WorkerSideFallback.prototype.terminate = function() {
    return easyWebWorkerInstance.worker.terminate();
  };

  _WorkerSideFallback.prototype.log = function() {
    return console.log.apply(console, arguments);
  };

  _WorkerSideFallback.prototype.execute = function() {
    var arg;

    return easyWebWorkerInstance.listen.call(easyWebWorkerInstance, {
      worker_fallback: true,
      data: (function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = arguments.length; _i < _len; _i++) {
          arg = arguments[_i];
          _results.push(arg);
        }
        return _results;
      }).apply(this, arguments)
    });
  };

  return _WorkerSideFallback;

})(_WorkerSideController);

_WorkerFallback = (function() {
  var importscripts_regexp;

  importscripts_regexp = /importScripts\("(.*)"\);?/gi;

  function _WorkerFallback(file, easyWebWorkerInstance, files, quene, depth, worker) {
    this.easyWebWorkerInstance = easyWebWorkerInstance;
    this.files = files != null ? files : {};
    this.quene = quene != null ? quene : [];
    this.depth = depth != null ? depth : 0;
    this.worker = worker != null ? worker : null;
    this.terminate = __bind(this.terminate, this);
    this._initializeScript = __bind(this._initializeScript, this);
    window._WorkerPrepared = true;
    this._loadFile(file, true);
  }

  _WorkerFallback.prototype._loadFile = function(file, is_main) {
    var XHR, content,
      _this = this;

    if (is_main == null) {
      is_main = false;
    }
    content = null;
    if (!is_main) {
      this.files[file].content = null;
    }
    XHR = new XMLHttpRequest() || new ActiveXObject("Msxml2.XMLHTTP") || new ActiveXObject("Microsoft.XMLHTTP");
    XHR.onreadystatechange = function() {
      if (XHR.readyState === 4 && (XHR.status === 200 || window.location.href.indexOf("http") === -1)) {
        content = XHR.responseText;
        if (is_main) {
          _this.files['main'] = {
            content: content,
            depth: 0
          };
        } else {
          _this.files[file].content = content;
        }
        return _this._importScripts(content);
      }
    };
    XHR.open('GET', file, true);
    return XHR.send(null);
  };

  _WorkerFallback.prototype._importScripts = function(content) {
    var all_loaded, data, filename, matched, matches, _i, _len, _ref, _ref1, _ref2,
      _this = this;

    matches = content.match(importscripts_regexp);
    if (matches != null) {
      this.depth++;
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        matched = matches[_i];
        this.files[matched.replace(importscripts_regexp, "$1")] = {
          content: void 0,
          depth: this.depth
        };
      }
    }
    _ref = this.files;
    for (filename in _ref) {
      data = _ref[filename];
      if (data.content === void 0 && filename !== "main") {
        this._loadFile(filename);
      }
    }
    all_loaded = true;
    _ref1 = this.files;
    for (filename in _ref1) {
      data = _ref1[filename];
      if (data.content === void 0 || data.content === null) {
        all_loaded = false;
      }
    }
    if (all_loaded) {
      while (this.depth--) {
        _ref2 = this.files;
        for (filename in _ref2) {
          data = _ref2[filename];
          if (data.depth === this.depth) {
            this.files[filename].content = this.files[filename].content.replace(importscripts_regexp, function(to_replace, filename, pos, content) {
              return _this.files[filename].content;
            });
          }
        }
      }
      return this._initializeScript(this.files.main.content);
    }
  };

  _WorkerFallback.prototype._initializeScript = function(script) {
    var command, _i, _len, _ref, _results,
      _this = this;

    (function() {
      var easyWebWorkerInstance, self;

      easyWebWorkerInstance = _this.easyWebWorkerInstance;
      eval(script);
      self = new _WorkerSideFallback();
      return _this.worker = function(command) {
        var args, event, funcContext, funcName;

        event = {
          caller: "WebBrowser",
          command: command
        };
        funcName = command[0];
        args = command.slice(1);
        args.unshift(event);
        if (funcName.indexOf(".") !== -1) {
          funcContext = funcName.split(".");
          funcContext.pop();
          funcContext = funcContext.join(".");
          funcContext = eval(funcContext);
        } else {
          funcContext = eval(funcName);
        }
        return eval(funcName).apply(funcContext, args);
      };
    })();
    _ref = this.quene;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      command = _ref[_i];
      _results.push(this.worker(command));
    }
    return _results;
  };

  _WorkerFallback.prototype.postMessage = function(command) {
    if (this.worker != null) {
      return this.worker(command);
    } else {
      return this.quene.push(command);
    }
  };

  _WorkerFallback.prototype.terminate = function() {
    return this.worker = function() {
      return null;
    };
  };

  return _WorkerFallback;

})();

if (this.document !== void 0 && !window.Worker && !window._WorkerPrepared) {
  window.Worker = _WorkerFallback;
}

if (this.document === void 0) {
  self.caller = new _WorkerSideController(self);
  self.execute = self.caller.execute;
  self.log = self.caller.log;
}

/*
//@ sourceMappingURL=easy-web-worker.map
*/
