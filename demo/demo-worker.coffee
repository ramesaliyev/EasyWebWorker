importScripts("../easy-web-worker.js")

getSquares = (event, numberArray) ->
  squares = (number * number  for number in numberArray)

  self.execute("getSquaresCallback", squares)

reverseText = (event, text) ->
  reversedText = text.split("").reverse().join("")

  self.execute("NestedFunctions.textPrinter.printToConsole", reversedText)