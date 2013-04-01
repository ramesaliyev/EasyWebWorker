EasyWebWorker
=============

Easy Communication Protocol For Web Workers.
Just execute worker functions from browser, and main functions from worker.

## Prepare

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

## Examples

### Example 1
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


### Example 2
Browser:
```javascript
// Execute function.
worker.execute("reverseText", "Hello guys wazzup?")

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
// Example 2
function reverseText(event, text){
  var reversedText = text.split("").reverse().join("");

  self.execute("NestedFunctions.textPrinter.printToConsole", text)
}
```
