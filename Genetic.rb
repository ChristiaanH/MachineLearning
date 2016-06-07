require_relative 'Ship'
require_relative 'AI'
require_relative 'NeuralNetwork'


class Genetic
	def self.evolve(oldPop, alterationPercent, mutationStrength) 
		sorted_pop = oldPop.sort_by do |a| 
			a.fitness
		end
		sorted_pop.reverse!
		numBreeders = oldPop.size / 2

		breeders = sorted_pop.slice!(0...numBreeders)

		children = breed_group(breeders, alterationPercent);
		mutate_group(children, alterationPercent, mutationStrength)
		families = children + breeders
		
		return families
	end

	def self.select_breeders(pop) 
		sorted_pop = pop.sort_by do |a| 
			a.fitness
		end

		amount = (pop.size / 2) - 2

		breeders = Array.new

		(2).times do 
			breeders << sorted_pop.shift()
		end

		amount.times do 
			r = rand(0.0...sorted_pop.size)

			breeders << sorted_pop.delete_at(r)
		end

		return breeders, sorted_pop
	end

	def self.breed_group(group, chromosome_father_percent)
		# puts "Group size: #{group.size}"
		father = group.slice!(0)
		milkman = group.first

		children = Array.new

		children << breed(milkman, group.last, chromosome_father_percent)

		group.each do |mother| 
			children << breed(father, mother, chromosome_father_percent)
		end

		group << father

		return children
	end

	def self.breed(father, mother, chromosome_father_percent)
		neuron_count_father = father.neuralNet.hidden_layer_neuron_count
		neuron_count_mother = mother.neuralNet.hidden_layer_neuron_count
		return false if neuron_count_father != neuron_count_mother # DNA Type mismatch!
		
		hlf = father.neuralNet.hidden_layers
		hlm = mother.neuralNet.hidden_layers
		num_layers = hlf.size

		neurons_mother = (neuron_count_mother * chromosome_father_percent).to_i
		neurons_father = neuron_count_father - neurons_mother

		layers = Array.new
		# Yes this can be done much quicker/shorter, but this conveys meaning 
		num_layers.times do 
			layers << Array.new
			neuron_count_father.times do
				node = Array.new
				(neurons_father).times do 
					node << 0
				end

				(neurons_mother).times do 
					node << 1
				end
				node.shuffle!
				layers.last << node
			end
		end
			
		child = AI.new
		hlc = child.neuralNet.hidden_layers

		layers.each_with_index do |layer, layer_index|
			layer.each_with_index do |node, node_index|
				node.each_with_index do |weight, weight_index|
					break if(layer_index == layers.size - 1 && weight_index >= child.neuralNet.output_layer.size - 1)
					if(weight == 0) then
						#puts "Old weight: #{hlc[layer_index][node_index].outgoing_connections[weight_index].weight} - #{hlf[layer_index][node_index].outgoing_connections[weight_index].weight} new weight"
						hlc[layer_index][node_index].outgoing_connections[weight_index].weight = hlf[layer_index][node_index].outgoing_connections[weight_index].weight
					else
						hlc[layer_index][node_index].outgoing_connections[weight_index].weight = hlm[layer_index][node_index].outgoing_connections[weight_index].weight
					end
				end
			end
		end

		return child
	end

	def self.mutate_group(group, alterationPercent, mutationStrength)
		group.each do |mutant|
			type = rand(0..1)
			mutate_random(mutant, alterationPercent, mutationStrength) if type == 0
			mutate_multiplication(mutant, alterationPercent, mutationStrength) if type == 1
		end

		return group
	end

	def self.mutate_multiplication(ai, alterationPercent, mutationStrength)
		numNeurons = ai.neuralNet.hidden_layer_neuron_count

		numMutations = numNeurons * alterationPercent

		hl = ai.neuralNet.hidden_layers

		hl.each do |i|
			i.each do |j|
				j.outgoing_connections.shuffle.take(numMutations).each do |o| 
					dir = rand(0..1)
					a = rand(0.0..mutationStrength) + dir

					o.weight = o.weight * a
				end
			end
		end
	end

	def self.mutate_random(ai, alterationPercent, mutationStrength) 
		numNeurons = ai.neuralNet.hidden_layer_neuron_count

		numMutations = numNeurons * alterationPercent

		hl = ai.neuralNet.hidden_layers

		hl.each do |i|
			i.each do |j|
				j.outgoing_connections.shuffle.take(numMutations).each do |o| 
					r = rand(0.0..mutationStrength)

					o.weight = r
				end
			end
		end
	end
end


# Activatie functie mutatie
# *1.5 gewicht mutatie
# individuele doden, mengen met huidige meest fitte
# sowieso breeden met meest fitte, [1,2],[1,3],[1,4]
# inverse mutatie *-1