#!/usr/bin/env ruby


# Main script-file for starting 'runner' program for
# Metric K-Center application.
#
# Error Codes
#   1   - JSON parse error of input file (invalid format)
#   2   - No input file provided
#   3   - Input file does not exist
#   4   - Input file is a directory
#   5   - Input file is not accessible


require 'peach'
require 'ruby-progressbar'
require 'pry'


s_COST = 1
GA_EVOLUTIONS = 1_500
GA_POPULATION_SIZE = 1_000


require_relative 'db/init'      # Defines CONNECT_POOL_SIZE
require_relative 'utils'
require_relative 'population'
require_relative 'woc'


# Public: Main entry point for 'runner' program. This method 
# is automatically executed as long as this file is run
# directly.
def main
  # load files
  filename    = get_filename
  file_handle = open_file(filename, 'r')

  # load data
  nodes   = Utils.parse(file_handle.read)
  k_range = ((nodes.length * 0.2).floor)...((nodes.length * 0.8).ceil)

  # init run_id for DB logging
  run_id = ("[%s]" % Time.now.to_s)

  # find solution(s)
  # Don't use entire connection pool (to avoid intermittent issues)
  k_range.peach(CONNECT_POOL_SIZE) do |k|

    # initialize run in DB
    db_result = init_db_run(k)

    # initialize the population
    population = Population.new(nodes.dup, {
      :run_id => db_result.run_id,
      :k => k,
      :size => GA_POPULATION_SIZE
    })
    population.record!

    # Do the evolutions and WoC's (the estimation)
    GA_EVOLUTIONS.times do
      population.evolve
      experts = population.experts
      consensus = WOC.consensus_of(experts, k: k)
      population << consensus
      population.record!
    end

    # Collect the final metrics
    best_solution = population.experts.first
    db_result.cost = best_solution.cost
    db_result.save

    # Close the thread-specific DB connection
    ActiveRecord::Base.connection.close
  end
end


# Public: Initialize the result-entry in the DB.
#
# Return the ActiveRecord DB entity
def init_db_run(k, run_id = nil)
  run_id ||= ("[%s]" % Time.now.to_s)

  result = Result.new do |r|
    r.run_id = run_id
    r.k = k
    r.ga_generations = GA_EVOLUTIONS
    r.ga_population_size = GA_POPULATION_SIZE
  end

  result.save
  result
end

# Public: Open the file by the filename provided, handling
# all access errors.
#
# Returns a file handle
def open_file(filename, mode)
  begin
    file_handle = File.open(filename, mode)
  rescue Errno::EACCES
    $stderr.puts 'Cannot access file provided. Try checking the permissions'
    print_help
    exit(5)
  end
end


# Public: Get the filename from the arguments passed into
# the command
#
# Returns a string
def get_filename
  filename = ARGV[0]
  unless filename
    $stderr.puts "No input file found \n"
    print_help
    exit(2)
  end

  unless File.exist? filename
    $stderr.puts "Input file provided does not exist"
    print_help
    exit(3)
  end

  if File.directory? filename
    $stderr.puts "Input file provided is a directory"
    print_help
    exit(4)
  end

  filename
end


# Public: Print the usage instructions on how to use this
# script to STDERR.
def print_help
  $stderr.puts 'Usage: main.rb [filename]'
  $stderr.puts
end



main if $0 == __FILE__