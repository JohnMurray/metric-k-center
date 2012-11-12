require_relative 'node'
require_relative 'individual'

# Public: Responsible for managing the population
# of solutions and their natural evolutionary process.
# This is where all the GA goodness really happens.
class Population

  # Public: Initialize a new population
  #
  # nodes - Set of nodes to use in each individual of the population
  # opts  - Extra options [optional]
  #         size - Size of population (number of individuals)
  #         k    - Number of s' in individual solution
  #
  # Returns [sortof] an instance of Population
  def initialize(nodes, opts = {})
    @nodes  = nodes || []
    @people = []
    @ranked = false

    @opts = opts        || {}
    @opts[:size]        ||= 100
    @opts[:k]           ||= (nodes.length * 0.25).ceil
    @opts[:expert_size] ||= 0.15

    init_people
  end


  # Public: sort the population, in-order, by the cost of the individual
  # solutions such that the most-optimal solutions are on top.
  def rank
    @people.sort! { |a,b| a.cost <=> b.cost }
    @ranked = true
  end


  # Public: Return the top-ranked individuals in the population. We
  # are calling these solution 'experts' because they are the best
  # within the current population.
  def experts
    rank unless @ranked
    num_experts = (@people.length * @opts[:expert_size]).ceil
    @people[0..(num_experts)]
  end


  # Public: Rank, breed, and trim the population to it's maximum size
  # as described by @opts[:size]. 
  def evolve
    # TODO: implement evolve method
    rank unless @ranked

    children = breed(experts)

    @ranked = false
  end



  private


  # Private: Given a set of people, breed them and return the children.
  #
  # people - ranked Array of Individual objects
  def breed(people)
    # TODO: implement breed method
  end

  # Private: Initialize all the people in the population. This means
  # generating random solutions where each person is represented by
  # that solution
  #
  # Returns nothing. Modifies the current instance.
  def init_people
    @opts[:size].times do 
      person = Individual.new(@nodes, @nodes.sample(@opts[:k]))
      @people << person
    end
  end
end