%w(generator rubygems enumerator).collect { |i| require i }

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Cpre
  VERSION = '0.0.1'
end

#Pathname.glob('lib/cpre/*').collect { |p| p.relative_path_from(Pathname('lib')).to_s.gsub('.rb', '') }
["cpre/base", "cpre/defaults", "cpre/kernel", "cpre/utilities", "cpre/validations"].collect { |i| require i }

=begin
def initialize(*args)
  #Parse in arguments into instance variables: @collect need to be a proc, 
  #@sources need to be a Hash of Enumerables, and @filters need to be an
  #array of procs
  @collect, @sources, @filters = case args.length
  when 3
    #this fits perfectly with what we are looking for
    args 
  when 2
    #If the first argument is a Proc it is must be @collect, and @sources musts be the
    #next argument.
    args[0].is_a?(Proc) ? [args[0], args[1], nil] :

    #If the first argument is a Hash it is must be @sources, and @filters musts be the
    #next argument.
    args[0].is_a?(Hash) ? [nil, args[0], args[1]] : 

    #If the first argument is a Array of Enumerables it is must be @sources.  It will 
    #be turned into a Hash using array2hash() and @filters musts be the next argument.
    is_all_enums?(args[0]) ? [nil, array2hash(args[0]), args[1]] :

    #If the first argument is an Enumerable it is must be @sources.  It will 
    #be turned into a Hash using array2hash() and @filters musts be the next argument.
    is_enum?(args[0]) ? [nil, array2hash([args[0]]), args[1]] :

    #At this point all options have been exhausted and nils will be returned.
    [nil, nil, nil]
  when 1
    [nil, args.first, nil]
  else 
    [nil, nil, nil]
  end

  check_arguments
end
=end













