require "delegate"
require "singleton"
require "forwardable"
require "rujitsu"

require "object/factory"

class Object
  include Factory::HelperMethods
end
