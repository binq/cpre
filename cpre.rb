%w'ostruct pathname'.each { |lib| require lib }

class Object
  autoload :ProcessingChain, Pathname(__FILE__).dirname + "lib/processing_chain"
  autoload :Comprehend, Pathname(__FILE__).dirname + "lib/comprehend"

  def ProcessingChain(*arguments, &predicate)
    block_given? ? ProcessingChain.new(*arguments, &predicate) : ProcessingChain.new(*arguments)
  end
  alias_method :Pchain, :ProcessingChain

  def Comprehend(*arguments, &predicate)
    block_given? ? Comprehend.new(*arguments, &predicate) : Comprehend.new(*arguments)
  end
  alias_method :Cpre, :Comprehend
end
