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


require_relative 'init'
require_relative 'utils'
require_relative 'population'



s_COST = 1
GA_EVOLUTIONS = 1_000


# Public: Main entry point for 'runner' program. This method 
# is automatically executed as long as this file is run
# directly.
def main
  # load files
  filename    = get_filename
  file_handle = open_file(filename, 'r')

  # load data
  nodes   = Utils.parse(file_handle.read)
  k_range = 1...(nodes.length)

  # find solution(s)
  k_range.peach do |k|
    puts k.inspect
    population = Population.new(nodes.dup, :k => k)
    GA_EVOLUTIONS.times do
      experts = population.experts
      # WoC to get consensus
      # add consensus back to pop
      population.evolve
    end
  end
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