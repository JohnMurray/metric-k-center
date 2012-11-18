require_relative 'node'
require_relative 'individual'
require_relative '../lib/array_ext'

# Public: Responsible for managing the population
# of solutions and their natural evolutionary process.
# This is where all the GA goodness really happens.
class Population

  MUTATION_RATE = 0.1

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
    @opts[:expert_size] ||= 0.05
    @opts[:run_id]      ||= "no-result-run"

    @generation_num = 1

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

    children = breed(experts)
    @people |= children

    @generation_num += 1

    rank
    trim
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


  # Public: Record the current best member of the population as a run-
  # entry within the DB. Note the `!` in the method-name as this funciton
  # has some pretty serious side-effects.
  def record!
    rank unless @ranked
    @ranked = true

    best = @people.first

    run = Run.new do |r|
      r.run_id = @opts[:run_id]
      r.k = @opts[:k]
      r.generation_num = @generation_num
      r.result_json = best.to_json
    end

    run.save
  end


  private


  # Private: Given a set of people, breed them and return the children.
  # When combining, we take the intersection, and then use a greedy
  # algorithm to select the other solution nodes 's'
  #
  # people - ranked Array of Individual objects
  #
  # Returns a 1-element Array of Individual objects
  def breed(people)
    p1, p2 = people

    intersect = p1.nodes_s & p2.nodes_s

    while intersect.length < @opts[:k]
      max_dist = 0
      furthest_node = nil

      intersect.each do |s|
        @nodes.each do |v|
          if v != s && v.distance_to(s) > max_dist
            max_dist = v.distance_to(s)
            furthest_node = v
          end
        end
      end

      intersect << furthest_node
    end

    [mutate(Individual.new(@nodes - intersect, intersect))]
  end


  # Private: Within a certain chance as defined by the MUTATION_RATE,
  # mutate a person that is given as a paramter. By mutate, we mean
  # alter it's set S such that the solution is changed randomly. This
  # is used in part with the GA to incorporate some randomness to avoid
  # getting stuck at a local maximum. 
  #
  # Right now, we're going to modify 20% of their s-nodes.
  #
  # person - Individual object
  #
  # Returns the Individual object given. However, change is done in-place
  def mutate(person)
    if rand > (1 - MUTATION_RATE)
      (person.nodes_s.length * 0.2).ceil.times do
        s = person.nodes_s.delete(person.nodes_s.sample)
        v = person.nodes_v.delete(person.nodes_v.sample)

        person.nodes_v << s
        person.nodes_s << v
      end
    end
    person
  end

  # Private: Initialize all the people in the population. This means
  # generating random solutions where each person is represented by
  # that solution
  #
  # Returns nothing. Modifies the current instance of this class.
  def init_people
    @opts[:size].times do
      nodes_s = @nodes.sample(@opts[:k])
      nodes_v = @nodes - nodes_s
      self << Individual.new(nodes_v, nodes_s)
    end
  end

end