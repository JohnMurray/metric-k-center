require_relative 'node'
require_relative 'individual'

# Public: Container for definitions related to the
# Wisdom of Crowds algorithm. Module contains no state,
# only definitions used in the calculations.
module WOC

  # Public: Consult he experts to generate a concensus on what
  # the best solution is.
  #
  # experts - the top Individual's from the Population
  # opts    - optional parameters
  #           k - |S|
  def self.consensus_of(experts opts = {})
    histogram = Hash.new(0)
    nodes_s = []
    k = opts[:k] || experts.first.nodes_s.length

    experts.each do |expert|
      expert.nodes_s.each do |s|
        histogram[s] += 1
      end
    end
    histogram = histogram.sort_by { |k,v| v }
    histogram.reverse!

    histogram.each do |node, count|
      break if nodes_s.length == k
      nodes_s << node
    end

    Individual.new(experts.first.nodes_v, nodes_s)
  end
end