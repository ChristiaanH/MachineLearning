require 'gosu'
require_relative 'ZOrder'

class Star
  attr_reader :x, :y
  
  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff_000000)
    @color.red = 255
    @color.green = 0
    @color.blue = 0
    @x = rand * WIDTH
    @y = rand * HEIGHT
    @angle = rand(0.0..360.0)
  end
  
  def draw
    # img = @animation[Gosu::milliseconds / 100 % @animation.size]
    # img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
    #    ZOrder::Stars, 1, 1, @color, :add)
    @animation.draw_rot(@x, @y, ZOrder::Stars, @angle)
  end
end