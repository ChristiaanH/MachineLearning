require 'gosu'
require_relative 'ZOrder'
require_relative 'Ship'
require_relative 'Star'
require_relative 'AI'
require_relative 'Genetic'

WIDTH, HEIGHT = 1024, 768
AICOUNT = 16
STARCOUNT = 32
DEFAULT_SCORE = 0
SCORELIMIT = 100
GENERATION_INTERVAL = 15.0

class GameWindow < Gosu::Window 
	def initialize
		super(WIDTH, HEIGHT)
		self.caption = "Genetisch algoritme"

		@background_image = Gosu::Image.new("media/space.png", :tileable => true)

		@generation = 1

		@score = DEFAULT_SCORE;
		@time_last_score_take = Time.now
    	@time_last_star_spawn = Time.now
    	@last_generation = Time.now
    	@AI = Array.new
	    
	    # @star_anim = Gosu::Image::load_tiles("media/star.png", 25, 25)
	    @star_anim = Gosu::Image.new("media/star.png", :tileable => true)
	    @stars = Array.new

	    for i in 0...AICOUNT do 
	    	ai = AI.new
	    	ai.ship.warp(rand * WIDTH, rand * HEIGHT)
	    	ai.ship.set_angle(rand(0.0..360.0))
	    	@AI.push(ai)
	    end

	    for i in 0...STARCOUNT do 
	    	@stars.push(Star.new(@star_anim))
	    end
	    
	    @font = Gosu::Font.new(20)
	end

	def update
	    if Gosu::button_down? Gosu::KbEscape then
	    	self.close
	    end

	    @AI.each do |ai|
	    	inputs = Array.new
	    	star = nearest_star(ai)
	    	#inputs << star.x << star.y << ai.x << ai.y
	    	inputs << Gosu::angle(ai.x, ai.y, star.x, star.y) - ai.ship.angle
	    	#inputs << nearest_ship_distance(ai)
	    	ai.think(inputs, @stars)
	    	@score += ai.score
	    end

	    if @score > SCORELIMIT then
	    	#self.close
	    	puts "Reached scorelimit #{@scorelimit} after #{@generation} generations"
	    	gets
	    end

	    clock
	end

	def get_angle(ai, star)
		angle = Gosu::angle(ai.x, ai.y, star.x, star.y)
		newAngle = (angle / 360.0) 
		# puts "newAngle: #{newAngle}"
		return newAngle
	end

	def nearest_star(ai)
		nearest_star = nil
		nearest_distance = 9999
		@stars.each	do |s|
			distance = Gosu::distance(s.x, s.y, ai.x, ai.y)
			if distance < nearest_distance then
				nearest_star = s
				nearest_distance = distance
			end
		end

		return nearest_star
	end

	def nearest_ship_distance(ai)
		nearest_ship = nil
		nearest_distance = 9999
		@AI.each do |s|
			next if ai == s
			distance = Gosu::distance(s.x, s.y, ai.x, ai.y)
			if distance < nearest_distance then
				nearest_ship = s
				nearest_distance = distance
			end
		end

		return nearest_distance
	end

	def clock 
		now = Time.now
	    if(now - @time_last_score_take > 1.0) then
	    	@score = @score - (@AI.size / 4).to_i
	    	@time_last_score_take = now
	    end

	    #if(now - @time_last_star_spawn > 0.01 and @stars.size < STARCOUNT) then
	    #	@stars.push(Star.new(@star_anim))
	    #	@time_last_star_spawn = now
	    #end

	    for i in 0...STARCOUNT - @stars.size do
	    	@stars.push(Star.new(@star_anim))
	    end

	    if(now - @last_generation > GENERATION_INTERVAL) then
	    	@score = DEFAULT_SCORE
	    	@generation += 1

	    	@AI = Genetic.evolve(@AI, 0.25, 0.2)

	    	@AI.each do |ai| 
	    		ai.ship.warp(rand * WIDTH, rand * HEIGHT)
	    		ai.ship.set_angle(rand(0.0...360.0))
	    		ai.fitness = 0
	    	end
	    	@last_generation = now
	    end
	end

	def draw
		@background_image.draw(0, 0, ZOrder::Background)
		@stars.each { |star| star.draw }
	    @AI.each do |ai| 
	    	ai.ship.draw 
	    	star = nearest_star(ai)
	    	self.draw_line(star.x, star.y, 0xFF00FFFF, ai.x, ai.y, 0xFF00FFFF, z = 0, mode = :default)
	    end
	    @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
	    @font.draw("Generation: #{@generation}", 10, 30, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
	    @font.draw("AI Count: #{@AI.size}", 10, 50, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
	end
end

window = GameWindow.new
window.show
