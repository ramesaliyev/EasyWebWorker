EasyWebWorker
=============

Easy Communication Protocol For Web Workers.
Just execute worker functions from browser, and main functions from worker.


Usage
-----

### On Browser

  ```javascript
    // Create EasyWebWorker
    var worker = new EasyWebWorker("worker.js", this);
    
    // Execute function
    worker.execute("getSquares", [2,3,5]);
    
    // And our callback function.
    function getSquaresCallback(event, squares) {
        console.log("Here is our squares: ",squares)
    }
    
  ```
  
### In Worker

  ```javascript
    importScripts("../easy-web-worker.js");
    
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
