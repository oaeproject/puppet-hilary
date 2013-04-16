require 'puppet/parser/functions'

module Puppet::Parser::Functions
  newfunction(:hieraptr, :type => :rvalue) do |arguments|
    
    hiera_var = arguments[0]
    default = arguments[1]

    raise(ArgumentError, 'Must provide an array of hiera variable names') unless hiera_var

    Puppet::Parser::Functions.function(:hiera)
    Puppet::Parser::Functions.function(:hiera_array)
    Puppet::Parser::Functions.function(:hiera_hash)

    # Get the hiera value, then fetch the hiera value with that value
    hiera_val = send("function_hiera", [hiera_var, default])
    return send("function_hiera", [hiera_val])
  end
end