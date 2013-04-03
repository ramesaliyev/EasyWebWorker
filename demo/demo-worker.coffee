importScripts("../easy-web-worker.js")

# Simple function.
getSquares = (event, numberArray) ->
  # Do stuff.
  squares = (number * number  for number in numberArray)

  # Call simple function.
  self.execute("getSquaresCallback", squares)

# Nested function.
textOperations =
  reverseText: (event, text) ->
    # Do stuff.
    reversedText = text.split("").reverse().join("")

    # Call nested function.
    self.execute("NestedFunctions.textPrinter.printToConsole", reversedText)