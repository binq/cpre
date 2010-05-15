%w(ostruct).collect { |i| require i }

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Cpre
  VERSION = '0.0.1'
end

#Pathname.glob('lib/cpre/*').collect { |p| p.relative_path_from(Pathname('lib')).to_s.gsub('.rb', '') }
%w(utilities base defaults kernel validations).collect { |i| require "cpre/%s" % i }

Cpre.class_eval { 
  const_set(:IN_SETUP, true)
  setup_in_kernel
  remove_const(:IN_SETUP)
}
