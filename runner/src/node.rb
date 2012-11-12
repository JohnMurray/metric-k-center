# Class for representing the nodes in the graph
# Although this class really isn't necessary, I was getting
# a little tired of representing everything through hashes.
# It just gets the the point where the hash adds too much syntax
# and it get's a little annoying.
class Node

  attr_accessor :x, :y
  attr_reader :name

  def initialize(opts = {})
    @name      = opts[:name] || ''
    @x         = opts[:x] || 0.0
    @y         = opts[:y] || 0.0
    @@cache    ||= Hash.new { |hash, key| hash[key] = {} }
  end


  def to_sym
    @name.to_sym
  end

  def to_s
    @name
  end

  # Calculate the distnace between this node and another node
  # that is passed in. 
  # Also, cache the value for faster lookup later (helps a lot!)
  def distance_to(n)
    return 0 unless n
    @@cache[self.object_id][n.object_id] ||= Math.sqrt((n.x - @x)**2 + (n.y - @y)**2)
  end

end