require "delegate"
require "singleton"
require "forwardable"

class Object

  autoload :Factory, "object/factory"

  include Factory::HelperMethods

end
