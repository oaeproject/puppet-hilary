require 'puppet/parser/functions'

module Puppet::Parser::Functions
  newfunction(:map_hieraptr, :type => :rvalue) do |arguments|
    
    hiera_var = arguments[0]
    hiera_default = arguments[1]

    raise(ArgumentError, 'Must provide an array of hiera variable names') unless hiera_var

    Puppet::Parser::Functions.function(:hiera)
    Puppet::Parser::Functions.function(:hiera_array)
    Puppet::Parser::Functions.function(:hiera_hash)

    hiera_val = send("function_hiera", [hiera_var, hiera_default])

    values = []
    hiera_val.each do |inner_var|
      values.push(send("function_hiera", [inner_var]))
    end

    return values
  end
end