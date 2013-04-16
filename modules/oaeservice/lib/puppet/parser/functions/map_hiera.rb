require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:map_hiera, :type => :rvalue) do |arguments|
  
  var_names = arguments[0] if arguments[0]
  hiera_function = arguments[1] if arguments[1]

  raise(ArgumentError, 'Must provide an array of hiera variable names') unless var_names

  hiera_function ||= 'hiera'

  Puppet::Parser::Functions.function(:hiera)
  Puppet::Parser::Functions.function(:hiera_array)
  Puppet::Parser::Functions.function(:hiera_hash)

  var_values = []

  var_names.each do |var_name|
    var_values.push(send("function_#{hiera_function}", var_name))
  end

  return var_values
end