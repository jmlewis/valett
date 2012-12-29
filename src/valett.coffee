class Valett
	init: (@words, @letters) ->
		@hash = {}
		@hash[@letters[i]] = i for i in [0...@letters.length]		

		@_metadata()
		
	analyze: (maxValue, weights, frequencyByLengthWeights, entropyWeights) ->
		normedFrequencyByLengthWeights = @norm frequencyByLengthWeights
		normedEntropyWeights = @norm entropyWeights
		
		frequencyByLengthValues = []
		entropyValues = []

		frequencyValues = @norm @metadata.frequency
		frequencyByLengthValues = @transposeMatrix @normMatrix @transposeMatrix @metadata.frequencyByLength
		entropyValues[i] = @norm @metadata.entropy[i] for i in [0..1]

		# Calculate utility using weights
		utility = []
		utility[i] = 0 for i in [0...@letters.length]

		utility[i] += frequencyValues[i] * weights.frequency for i in [0...@letters.length]

		for i in [0...@metadata.maxLength]
			for j in [0...@letters.length]
				utility[j] += frequencyByLengthValues[j][i] * normedFrequencyByLengthWeights[i] * weights.frequencyByLength
				
		for i in [0..1]
			for j in [0...@letters.length]
				utility[j] += entropyValues[i][j] * normedEntropyWeights[i] * weights.entropy

		# Invert and scale to [0, 1]
		utility[i] = 1 / utility[i] for i in [0...@letters.length]
		maxUtility = 0
		for i in [0...@letters.length]
			maxUtility = utility[i] if utility[i] > maxUtility
		utility[i] /= maxUtility for i in [0...@letters.length]
		
		# Scale to desired range, could end up with zeros
		utility[i] = Math.round(utility[i] * maxValue) for i in [0...@letters.length]
		
		@values = utility
					
	norm: (vector) ->
		sum = 0
		normedVector = []
		
		sum += num for num in vector
		for i in [0...vector.length]
			if sum
				normedVector[i] = vector[i] / sum
			else
				normedVector[i] = 0 # Ignore zero vectors
		
		normedVector
		
	normMatrix: (matrix) ->
		normedMatrix = []
		normedMatrix[i] = [] for i in [0...matrix.length]

		normedMatrix[i] = @norm matrix[i] for i in [0...matrix.length]
		
		normedMatrix
		
	transposeMatrix: (matrix) ->
		transposedMatrix = []
		transposedMatrix[i] = [] for i in [0...matrix[0].length]
		
		for i in [0...matrix[0].length]
			for j in [0...matrix.length]
				transposedMatrix[i][j] = matrix[j][i]
				
		transposedMatrix

	_metadata: ->
		@metadata = {}
		@_maxLength()
		@_frequency()
		@_frequencyByLength()
		@_transitionFrequency()
		@_entropy()

	_maxLength: ->
		@metadata.maxLength = 0
		for word in @words
			@metadata.maxLength = word.length if word.length > @metadata.maxLength

	_frequency: ->
		@metadata.frequency = []
		@metadata.frequency[i] = 0 for i in [0...@letters.length]
		for word in @words
			if word.length
				@metadata.frequency[@hash[letter]]++ for letter in word
	
	_frequencyByLength: ->
		@metadata.frequencyByLength = []
		@metadata.totalFrequencyByLength = []

		for i in [0...@letters.length]
			@metadata.frequencyByLength[i] = []
			for j in [0...@metadata.maxLength]
				@metadata.frequencyByLength[i][j] = 0
		
		@metadata.totalFrequencyByLength[i] = 0 for i in [0...@metadata.maxLength]
		
		for word in @words
			@metadata.totalFrequencyByLength[word.length - 1] += word.length
			for letter in word
				@metadata.frequencyByLength[@hash[letter]][word.length - 1]++
				
		for i in [0...@letters.length]
			for j in [0...@metadata.maxLength]
				@metadata.frequencyByLength[i][j] /= @metadata.totalFrequencyByLength[j] if @metadata.totalFrequencyByLength[j] isnt 0
				
	_transitionFrequency: ->
		@metadata.transitionFrequency = []
		for i in [0..@letters.length] # Extra slot for start/end of word
			@metadata.transitionFrequency[i] = [] 
			for j in [0..@letters.length]
				@metadata.transitionFrequency[i][j] = 0

		for word in @words
			for letter, i in word
				if i is 0
					@metadata.transitionFrequency[@letters.length][@hash[letter]]++
					@metadata.transitionFrequency[@hash[letter]][@hash[word[i + 1]]]++
				else if i is word.length - 1
					@metadata.transitionFrequency[@hash[word[i - 1]]][@hash[letter]]++
					@metadata.transitionFrequency[@hash[letter]][@letters.length]++
				else
					@metadata.transitionFrequency[@hash[word[i - 1]]][@hash[letter]]++
					@metadata.transitionFrequency[@hash[letter]][@hash[word[i + 1]]]++
	
	_entropy: ->
		inOut = []
		inOut[0] = @normMatrix @transposeMatrix @metadata.transitionFrequency
		inOut[1] = @normMatrix @metadata.transitionFrequency
		
		# Prevent zero probability
		for i in [0..1]
			for j in [0..@letters.length]
				for k in [0..@letters.length]
					inOut[i][j][k] = .000000001 if inOut[i][j][k] is 0
					
		@metadata.entropy = [[], []]
		for i in [0..1]
			for j in [0...@letters.length] # Ignore start/end
				@metadata.entropy[i][j] = 0
				for k in [0..@letters.length]
					@metadata.entropy[i][j] -= inOut[i][j][k] * (Math.log(inOut[i][j][k]) / Math.LN2)
				
module.exports = new Valett