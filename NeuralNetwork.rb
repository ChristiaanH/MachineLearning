module Activation
	def binary_step(input)
		return 1 if (input > 0)
		return 0
	end

	def logistic(input) 	# softstep
		
	end

	def sigmoid(input)	# TanH
		return Math.tanh(input)
	end

	def softsign(input)
		
	end

	def softplus(input)

	end

	def gaussian(input)

	end
end

class Node
	attr_accessor :incoming_connections
	attr_accessor :outgoing_connections
	attr_reader :value

	include Activation

	def initialize
		@incoming_connections = Array.new
		@outgoing_connections = Array.new
		@value = 0
		@values = Array.new
	end

	def add_outgoing_connection(aConnection)
		@outgoing_connections << aConnection
	end

	def add_incoming_connection(aConnection)
		@incoming_connections << aConnection
	end

	def feed_forward(aValue)
		@values << aValue

		if(@values.size == @incoming_connections.size) then
			@value = @values.inject(0.0) { |sum, el| sum + el } / @values.size
			if(@outgoing_connections.size > 0) then
				@outgoing_connections.each do |c|
					c.send(sigmoid(@value))
				end
			end
			@values.clear
		end
	end
end

class Connection
	attr_accessor :previous
	attr_accessor :next
	attr_accessor :weight

	def initialize(range)
		@weight = rand(0.0...range)
	end

	def send(value)
		@next.feed_forward(value*@weight)
	end
end

class NeuralNetwork
	attr_reader :input_layer
	attr_reader :hidden_layers
	attr_reader :hidden_layer_neuron_count
	attr_reader :output_layer

=begin
	Extract function for creating network:

	layer_add_nodes(outerrange, innerrange, list)
=end
	def initialize(numInputs, numHidden, numNeuronsPerHiddenLayer, numOutputs, weightRange)
		@input_layer = Array.new
		@hidden_layers = Array.new
		@output_layer = Array.new
		@hidden_layer_neuron_count = numNeuronsPerHiddenLayer

		for i in 0...numInputs do 
			@input_layer << Node.new
			@input_layer[i].add_incoming_connection(Connection.new(0))
		end

		@hidden_layers << Array.new

		oldlayer = hidden_layers[0]

		for i in 0...numNeuronsPerHiddenLayer do
			n = Node.new
			@input_layer.each do |p|
				c = Connection.new(weightRange)
				c.previous = p
				c.next = n
				p.add_outgoing_connection(c)
				n.add_incoming_connection(c)
			end
			oldlayer << n
		end

		oldlayer = hidden_layers[0]

		for i in 1...numHidden do 
			l = Array.new
			for j in 0...numNeuronsPerHiddenLayer do 
				n = Node.new
				
				oldlayer.each do |o|
					c = Connection.new(weightRange)
					c.previous = o
					c.next = n
					o.add_outgoing_connection(c)
					n.add_incoming_connection(c)
				end

				l << n
			end
			@hidden_layers << l
			oldlayer = l
		end

		for i in 0...numOutputs do 
			n = Node.new
			oldlayer.each do |o|
					c = Connection.new(weightRange)
					c.previous = o
					c.next = n
					o.add_outgoing_connection(c)
					n.add_incoming_connection(c)
				end
			@output_layer << n
		end
	end

	def feed(inputs)
		puts "Incorrect amount of inputs!" if(inputs.size != @input_layer.size)

		inputs.each_with_index do |input, input_index|
			@input_layer[input_index].feed_forward(input)
		end

		@output_layer.collect {|i| i.value}
	end
end