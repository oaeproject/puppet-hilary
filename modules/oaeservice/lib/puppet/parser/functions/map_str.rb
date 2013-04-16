require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:map_str, :type => :rvalue) do |vals|
  strs, val = vals

  raise(ArgumentError, 'Must provide an array of strings for the first argument') unless strs
  raise(ArgumentError, 'Must provide a string value for the second argument') unless val

  str_values = []

  strs.each do |str|
    str_values.push(str.gsub("%s", [val]))
  end

  return str_values
end