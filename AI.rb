require_relative 'Ship'
require_relative 'NeuralNetwork'

class AI
	attr_accessor :ship
	attr_accessor :score
	attr_accessor :fitness
	attr_accessor :neuralNet

	def initialize
		@ship = Ship.new 
		#@neuralNet = NeuralNetwork.new(4,1,6,2,1.0)	#numInputs, numHidden, numNeuronsPerHiddenLayer, numOutputs, weightRange
		@neuralNet = NeuralNetwork.new(1,2,2,2,1.0)	#numInputs, numHidden, numNeuronsPerHiddenLayer, numOutputs, weightRange
		@fitness = 0
	end

	def think(inputs, stars)
		@ship.accelerate

		outputs = @neuralNet.feed(inputs)

		@ship.turn_left(outputs[0] * 90) 
		@ship.turn_right(outputs[1] * 90) 

		@ship.move
		@ship.collect_stars(stars)
		@score = @ship.score
		@fitness += @ship.score
	end

	def x
		return @ship.x
	end

	def y
		return @ship.y
	end
end