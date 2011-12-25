require "delegate"
require "singleton"
require "forwardable"
require "rujitsu"

class Object

  autoload :Factory, "object/factory"

  include Factory::HelperMethods

end
