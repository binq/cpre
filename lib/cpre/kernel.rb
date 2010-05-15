class << Cpre
  def setup_in_kernel(options={})
    return if respond_to?(:dont_setup_in_kernel) && send(:dont_setup_in_kernel) && respond_to?(:in_setup)

    cpre_methods = %w(c cpre comprehend)
    cpre_methods = options[:without].is_a?(Array) ? cpre_methods - options[:without] : 
                   options[:without].is_a?(String) ? cpre_methods - [options[:without]] :
                   cpre_methods
    cpre_methods = options[:as].is_a?(Array) ? cpre_methods + options[:as] : 
                   options[:as].is_a?(String) ? cpre_methods + [options[:as]] :
                   cpre_methods

    Kernel.module_eval do
      cpre_methods.each do |cpre_method|
        eval(<<-EOT % [cpre_method])
          def %s(*args, &block)
            block_given? ? Cpre.new(*args, &block) : Cpre.new(*args)
          end
        EOT
      end
    end
  end

  def setup_in_array(options={})
    return if respond_to?(:dont_setup_in_array) && send(:dont_setup_in_array) && respond_to?(:in_setup)
  end

  def setup_in_hash(options={})
    return if respond_to?(:dont_setup_in_hash) && send(:dont_setup_in_hash) && respond_to?(:in_setup)
  end
end
