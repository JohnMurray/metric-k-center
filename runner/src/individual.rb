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

end