module Cpre::ArgsParser
  module ClassMethods
    def parse(*args, &block)
      block_given? ? Cpre.new(:sources => args, &block) : Cpre.new(:sources => args)
    end
  end
  
  module InstanceMethods
    #returns a new comprehension with the values supplied through the ArgsParserDsl
    def update(&block)
      raise ArgumentError unless block_given?
      options = Hash[*MAIN_ARGS.collect { |i| [i.to_sym, send(i.to_sym)] }.flatten]
      Cpre.new(update_options(options, &block))
    end
    
    private
    
    #get new arguments from the ArgsParserDsl and return a hash that can be used to instantiate a new comprehension
    def update_options(options, &block)
      raise ArgumentError unless block_given?

      Hash[*Cpre::MAIN_ARGS.inject(:parsed => Cpre::ArgsParserDsl.new(options).dsl_eval(&block), :result => []) { |memo, i| 
        memo[:result] << i.to_sym << memo[:parsed].send(i)
        memo
      }[:result]]
    end
  end

  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
end

Cpre.class_eval { include self::ArgsParser }
