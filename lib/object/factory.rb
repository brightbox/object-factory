class Object
  class Factory
    include Singleton
    extend Forwardable

    autoload :HelperMethods,      "object/factory/helper_methods"
    autoload :TemplateCollection, "object/factory/template_collection"
    autoload :Template,           "object/factory/template"
    autoload :ValueGenerator,     "object/factory/value_generator"

    def_delegators :generator, :value_for, :unique_integer, :next_number, :a_number

    CannotSaveError = Class.new(RuntimeError)

    attr_writer :generator
    attr_writer :templates

    def generator
      @generator ||= ValueGenerator.new
    end

    def templates
      @templates ||= TemplateCollection.new
    end

    def reset
      @templates = @generator = nil
    end

    def when_creating_a klass, params={}
      params ||= {}
      clean_up = params.delete(:clean_up) # todo: handle
      self.templates << Template.new({:klass => klass}.merge(params))
    end
    alias when_creating_an when_creating_a

    def create_a klass, params={}, &block
      templates.template_for(klass).create_instance_with(params, &block)
    end

    def create_and_save_a *args, &block
      instance = create_a(*args, &block)
      raise CannotSaveError, instance.errors.inspect unless instance.save
      instance
    end
  end
end
