require 'json'
require_relative 'node'

# Contians misc. definitions that don't really logically
# belong anywhere else or as part of a class.
module Utils
  def self.parse(file)
    begin
      locs = JSON.parse(file)
    rescue
      Utils.log('Failed to parse provided JSON file')
      exit(1)
    end

    locs.map do |loc|
      x = loc[:x].to_f
      y = loc[:y].to_f
      Node.new({x: x, y: y})
    end
  end

  def self.log(msg)
    time = Time.now.strftime("[%Y-%m-%d %H:%M:%S]")
    $stderr.puts( "%s  %s" % [time, msg] )
  end
end