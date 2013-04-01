importScripts("../easy-web-worker.js")

getSquares = (event, numberArray) ->
  squares = (number * number  for number in numberArray)

  self.execute("getSquaresCallback", squares)
