class Object
  class Factory
    class Template
      extend Forwardable
      def_delegator :generator, :value_for

      attr_accessor :klass, :generate, :set, :auto_generate, :auto_confirm, :after_create

      autoload :InstanceBuilder, "object/factory/template/instance_builder"

      def initialize opts={}
        opts ||= {}
        opts.each {|k,v| send "#{k}=", v }
      end

      def eql? obj
        obj.respond_to?(:klass) && klass == obj.klass
      end

      def hash
        "#{klass}".hash
      end

      def create_instance_with params={}, &block
        InstanceBuilder.new(:params => params, :template => self, &block).instance.tap do |i|
          after_create.call(i) if after_create
        end
      end

      def generate
        @generate ||= {}
      end

      def set
        @set ||= {}
      end

      def default_params
        h = set.dup
        generate.each do |k,blk|
          h[k] = blk.call
        end
        h.merge!(auto_generated_params)
        Array(auto_confirm).each do |field|
          val = value_for(klass, field)
          confirm_field = :"#{field}_confirmation"
          h[field] = val unless h.has_key?(field)
          h[confirm_field] = val unless h.has_key?(confirm_field)
        end
        h
      end

      def auto_generated_params
        Array(auto_generate).inject({}) do |hash, field|
          hash[field] = value_for(klass, field)
          hash
        end
      end

      def generator
        Object.factory.generator
      end

    end
  end
end
