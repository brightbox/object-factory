require "delegate"
require "singleton"
require "forwardable"
require "rujitsu"

module ObjectFactory
  autoload :InstanceBuilder, "object_factory/instance_builder"
  autoload :TemplateCollection, "object_factory/template_collection"
  autoload :Template,           "object_factory/template"
  autoload :ValueGenerator,     "object_factory/value_generator"

  class Factory
    include Singleton
    extend Forwardable

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
      self.templates << Template.new({:klass => klass}.merge(params))
    end
    alias when_creating_an when_creating_a

    def create_a klass, params={}, &block
      template = templates.template_for(klass)
      instance = template.create_instance_with(params, &block)
      if template.after_build
        template.after_build.call(instance)
      end
      instance
    end

    def create_and_save_a klass, params = {}, &block
      template = templates.template_for(klass)
      instance = template.create_instance_with(params, &block)
      if template.after_build
        template.after_build.call(instance)
      end

      raise CannotSaveError, instance.errors.inspect unless instance.save
      if template.after_create
        template.after_create.call(instance)
      end
      instance
    end

    def clean_up
      templates.classes_for_cleaning.each &:delete_all
    end
  end
end
