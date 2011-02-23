#!/usr/bin/env ruby

require "rubygems"
require "optparse"
require "facter"

# Load an array of CSV files (as string paths)
# Returns a hash of the first column as the key with the rest of the 
# row as an array.
def csv2hash(paths)
  data = {}
  paths.each do |path|
    next unless File.exists?(path)
    csv = CSV.read(path).find_all do |row|
      next if data[row[0]]
      data[row[0]] = row[1..-1]
    end # CSV.read.find_all
  end # paths.each
  return data
end # csv2hash

# Return the string with any %{foo} values replaced with the fact value 'foo'
def facter_to_str(str)
  return str.gsub(/%\{[^}]+\}/) do |sub|
    Facter.fact(sub[2...-1]).value rescue sub
  end
end

datadir = nil
precedence = []
withnames = false
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] csvkey defaultval"

  opts.on("--datadir DATADIR", "Set a datadir (like extlookup_datadir)") do |dir|
    datadir = dir
  end

  opts.on("-p ARG", "--precedence ARG", "Set precedence paths") do |arg|
    precedence << arg
  end

  opts.on("--withnames", "Include the extlookup names in output") do 
    withnames = true
  end
end

args = parser.parse(ARGV)

precedence = [ 
  "%{deployment}/%{fqdn}", "%{deployment}/config", 
  "common", "truth" 
]

Facter.loadfacts

# Take the precedence paths and expand %{...} on them
csv_files = precedence.collect do |str|
  file = facter_to_str(str) + ".csv"
  File.join(datadir, file)
end

data = csv2hash(csv_files)

# For each command line argument, output the extlookup value.
# If the value is an array, join by comma.
args.each do |key|
  value =  data[key].collect { |s| facter_to_str(s) }.join(",")
  if withnames
    puts [key, "=>", value].join(" ")
  else
    puts value
  end
end
