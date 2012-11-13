require_relative 'node'
require_relative 'individual'
require_relative '../lib/array_ext'

# Public: Responsible for managing the population
# of solutions and their natural evolutionary process.
# This is where all the GA goodness really happens.
class Population

  MUTATION_RATE = 0.05

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
    rank unless @ranked
    @ranked = true

    children = breed(experts)
    pop_cap = @people.length
    @people |= children

    rank
    @people = @people[0...pop_cap]
  end


  # Public: Append an individual to the population and set the ranked
  # flag to false.
  def <<(individual)
    @people << individual
    @ranked = false
  end


  # Public: Trim the population down so that we do not exceed the max
  # as defined by @opts[:size].
  def trim
    rank unless @ranked
    @people.pop while @people.count > @opts[:size]
    @ranked = true
  end


  private


  # Private: Given a set of people, breed them and return the children.
  #
  # people - ranked Array of Individual objects
  #
  # Returns a 2-element Array of Individual objects
  def breed(people)
    # TODO: implement breed method
    p1, p2 = people
    intersect = p1.nodes_s & p2.nodes_s

    s1 = p1.nodes_s.odd_values | p2.nodes_s.even_values
    s2 = p1.nodes_s.even_values | p2.nodes_s.odd_values

    intersect.each {|i| s1.unshift(i); s2.unshift(i); }

    s1.uniq!
    s2.uniq!

    s1.push(p1.nodes_v.sample) while s1.length < @opts[:k]
    s2.push(p1.nodes_v.sample) while s1.length < @opts[:k]

    s1.pop while s1.length > @opts[:k]
    s2.pop while s2.length > @opts[:k]

    [
      mutate(Individual.new(p1.nodes_v, s1)),
      mutate(Individual.new(p1.nodes_v, s2))
    ]
  end


  # Private: Within a certain chance as defined by the MUTATION_RATE,
  # mutate a person that is given as a paramter. By mutate, we mean
  # alter it's set S such that the solution is changed randomly. This
  # is used in part with the GA to incorporate some randomness to avoid
  # getting stuck at a local maximum. 
  #
  # person - Individual object
  #
  # Returns the Individual object given. However, change is done in-place
  def mutate(person)
    if rand > (1 - MUTATION_RATE)
      person.nodes_s.delete(person.nodes_s.sample)
      person.nodes_s.push(person.nodes_v.sample)
    end
    person
  end

  # Private: Initialize all the people in the population. This means
  # generating random solutions where each person is represented by
  # that solution
  #
  # Returns nothing. Modifies the current instance.
  def init_people
    @opts[:size].times do 
      self << Individual.new(@nodes, @nodes.sample(@opts[:k]))
    end
  end

end