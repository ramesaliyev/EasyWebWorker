> # This library is not in development anymore because of great alternatives, use one of them; [parallel.js](https://github.com/adambom/parallel.js), [operative](https://github.com/padolsey/operative), [catiline](https://github.com/calvinmetcalf/catiline).

**Easywebworker v0.2.1**<br>
Easy Communication Protocol For Web Workers<br>
*Just execute worker functions from browser, and main functions from worker.*

> Also work when web worker is not available. So support Web Worker on older Internet Explorers.

# Features
- Fallback support for old browsers. (AKA Internet Explorer Support.)
- Execute functions directly. Nested functions are supported.
- Execute global functions from worker.
- Start Worker with startup data.
- Alias for console.log for ease debugging.

# Changelog
- 0.2.1 - XDomainRequest Fallback Support added for crossdomain request on older internet explorers.

# Prepare

### On Browser

```javascript
// Just include script to page and create EasyWebWorker with context.
var worker = new EasyWebWorker("worker.js", this);
```

### In Worker

```javascript
// Just import script.
importScripts("easy-web-worker.js");
```

# Methods
Error Statement (On browser.):
```javascript
worker.onerror = function(event,filename,lineno,message){
    // ...
}
```

Terminate From Browser:
```javascript
worker.terminate();
// or
worker.close();
```

Terminate In Worker (Same as default.):
```javascript
self.close();
```

# Examples

### Example 1 (Simple Usage)
Browser:
```javascript
// Execute function
worker.execute("getSquares", [2,3,5]);

// And our callback function.
function getSquaresCallback(event, squares) {
    console.log("Here is our squares: ",squares)
}
```

Worker:
```javascript
function getSquares(event, numberArray){
    // Do stuff.
    squares = [];
    for(var i=0, len=numberArray.length; i<len; i++){
        number = numberArray[i];
        squares.push(number*number);
    }

    // Call our callback function.
    self.execute("getSquaresCallback", squares);
}
```


### Example 2 (Nested Functions)
Browser:
```javascript
// Execute function.
worker.execute("textOperations.reverseText", "Hello guys wazzup?")

// Our nested callback function.
var NestedFunctions = {
  textPrinter: {
      printToConsole: function(event, textToPrint) {
          console.log("Here is our reversed text: ", textToPrint, this)

          // Context test.
          this.printToTitle(textToPrint)
      },
      printToTitle: function(text) {
          window.document.title = text
      }
  }
}
```
Worker:
```javascript
// Our nested function.
textOperations = {
  reverseText: function(event, text) {
    var reversedText = text.split("").reverse().join("");
    return self.execute("NestedFunctions.textPrinter.printToConsole", reversedText);
  }
};
```

### Example 3 (Startup Data)<br>
(It uses worker file's querystring. So keep it as tiny as possible.)
Browser:
```javascript
// Create startup data.
var startupData = {name:"Derp", surname:"Derpson", age:"23"}

// Create worker with startupData.
var workerTwo = new EasyWebWorker('demo-worker.js', this, startupData)

// Execute worker.
workerTwo.execute("whatIsTheSettings")

// Get our startupData back.
getSettingsBack = function(event, startupData){
    console.log("Here is our startup data: ", startupData)
}
```

Worker:
```javascript
function whatIsTheSettings(){
    // Give settings back.
    self.execute("getSettingsBack", self.startupData)
}
```

### Example 4 (Call Global Function)<br>
Worker:
```javascript
self.execute("window.console.log", "Hello world!")

// There is an alias for console log.
self.log("Hello World!")
```
