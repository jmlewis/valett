fs = require 'fs'

words = fs.readFileSync './twl.txt', 'utf8'
words = words.split /[^A-z]+/
letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

valett = require './valett'
valett.init words, letters

weights = {frequency: .34, frequencyByLength: .33, entropy: .33}
frequencyByLengthWeights = [0, 50, 25, 5, 2.5, 1.25, 0.625, 25, 12.5, 2.5, 1.25, 0, 0, 0, 0]
entropyWeights = [.5, .5]

valett.analyze 10, weights, frequencyByLengthWeights, entropyWeights

console.log "#{letter}: #{valett.values[valett.hash[letter]]}" for letter in letters
