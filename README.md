# Valett

Valett is a Node module for determining the appropriate letter and board valuations in word games. Valett analyzes the corpus of a game's legal plays and provides point values for the letters in the game based on a desired weighting of their frequency, frequency by length and the entropy of their transition probabilities.

## Installation

Install via NPM:

	npm install valett

## Usage

From the Scrabble example (CoffeeScript):

	valett = require 'valett'
	valett.init words, letters
	
	weights = {frequency: .34, frequencyByLength: .33, entropy: .33}
	frequencyByLengthWeights = [0, 50, 25, 5, 2.5, 1.25, 0.625, 25, 12.5, 2.5, 1.25, 0, 0, 0, 0]
	entropyWeights = [.5, .5]
	
	valett.analyze 10, weights, frequencyByLengthWeights, entropyWeights
	
	console.log "#{letter}: #{valett.values[valett.hash[letter]]}" for letter in letters
	
Where words is an array of acceptable words and letters is a sorted array of unique letters.

valett.analyze:
	
	valett.analyze maxValue, weights, frequencyByLengthWeights, entropyWeights
	
maxValue is a scaling term for determining the highest possible letter value.

weights is an object whose fields determine the relative weighting of frequency, frequency by length, and entropy when calculating letter values. The fields should sum to 1.

frequencyByLengthWeights should be the length of the longest word in the corpus, and reflects the relative value of a letter's occurrence in words of different length. For example, in Scrabble it is particularly valuable for a letter to appear in 2, 3, 7 and 8 length words.

entropyWeights should be length 2, and reflects the relative value of the ease of transitioning into a letter (how evenly the transition probabilities toward a letter are distributed) and out of a letter. For example, Q has a low entropy out since its transition probability distribution is highly peaked at U.

## Contact

Contact [Joshua Lewis](josh@useost.com) with comments and suggestions. The code is MIT licensed and pull requests with analyses for other games or new corpus metadata are welcome!