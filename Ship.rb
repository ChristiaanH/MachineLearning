require 'gosu'
require_relative 'ZOrder'

class Ship
  attr_reader :score
  attr_reader :x, :y
  attr_reader :angle
  
  def initialize
    @image = Gosu::Image.new("media/starfighter.png")
    @beep = Gosu::Sample.new("media/beep.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end
  
  def warp(x, y)
    @x, @y = x, y
  end
  
  def turn_left(amount)
    @angle -= amount
  end
  
  def turn_right(amount)
    @angle += amount
  end

  def set_angle(value)
  	@angle = value
  end
  
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= WIDTH
    @y %= HEIGHT
    
    @vel_x *= 0.75
    @vel_y *= 0.75
  end
  
  def draw
    @image.draw_rot(@x, @y, ZOrder::Ship, @angle)
  end
  
  def collect_stars(stars)
  	@score = 0
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 12 then
        @score += 1
        #@beep.play
        true
      else
        false
      end
    end
  end
end