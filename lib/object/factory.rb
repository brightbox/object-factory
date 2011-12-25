class Object
  class Factory
    include Singleton
    extend Forwardable

    autoload :HelperMethods,      "object/factory/helper_methods"
    autoload :ValueGenerator,     "object/factory/value_generator"

    def_delegators :generator, :value_for, :unique_integer, :next_number, :a_number

    CannotSaveError = Class.new(RuntimeError)

    attr_writer :generator

    def generator
      @generator ||= ValueGenerator.new
    end

    def reset
      @generator = nil
    end

    def when_creating_a klass, params={}
    end
    alias when_creating_an when_creating_a

    def create_a klass, params={}, &block
    end

    def create_and_save_a *args, &block
    end
  end
end
