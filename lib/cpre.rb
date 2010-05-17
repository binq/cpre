%w(ostruct).collect { |i| require i }

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Cpre
  VERSION = '0.0.1'
end

#Reordered from:
#%(%w()).insert(-2, Pathname.glob('lib/cpre/*').collect { |p| p.relative_path_from(Pathname('lib')).to_s.gsub('.rb', '').gsub(/^cpre./, '') }.join(' '))
%w(utilities base defaults validations args_parser args_parser_dsl ops setup).collect { |i| require "cpre/%s" % i }

Cpre.class_eval { 
  const_set(:IN_SETUP, true)
  setup_in_kernel
  # setup_in_array
  # setup_in_hash
  remove_const(:IN_SETUP)
}
