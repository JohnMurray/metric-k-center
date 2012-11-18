require_relative 'node'

# Public: Represents the individual solution within the population.
class Individual

  attr_reader :nodes_v, :nodes_s

  # Public: Create a new instance of Individual via the provided
  # data.
  #
  # Returns [sortof] a new instance of Individual
  def initialize(nodes_v, nodes_s)
    @nodes_v = nodes_v
    @nodes_s = nodes_s
    @cost = nil
  end


  # Public: Calculate the cost for the individual and cache it at
  # the nistance level.
  #
  # Returns the cost for the soltuion.
  def cost
    unless @cost
      @cost = 0
      @nodes_v.each do |v|
        @cost += @nodes_s.map { |s| v.distance_to(s) }.min
      end
    end

    @cost
  end


  # Public: Convert the Individual 'solution-object' into something
  # that is meaningful to the renderer (in JS).
  #
  # Returns a string in valid JSON notation.
  def to_json
    json_obj = []

    nodes = @nodes_s | @nodes_v
    nodes.each do |n|
      s = closest_s(n).name if @nodes_v.include?(n)
      json_obj << {
        name: n.name,
        coord: {x: n.x, y: n.y},
        s: s
      }
    end

    json_obj.to_json
  end


  # Return the closest s-node to the v-node given. Note that
  # no validation is done to ensure that the node given is
  # actually a v-node.
  #
  # Returns an s-node (Node) object
  def closest_s(v)
    @nodes_s.map { |s| [s, v.distance_to(s)] }.min_by { |a| a[1] }.first
  end

end