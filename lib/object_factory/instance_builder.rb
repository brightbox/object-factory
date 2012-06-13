module ObjectFactory
  class InstanceBuilder
    attr_accessor :instance, :template, :params

    def initialize opts={}, &block
      opts ||= {}
      opts.each {|k,v| send "#{k}=", v }

      if template.klass.respond_to?(:accessible_attributes)
        self.instance = template.klass.new(mass_assignable_params)
        set_protected_attributes
      else
        self.instance = template.klass.new(create_params)
      end
      block.call(instance) if block
    end

    def params
      @params ||= {}
    end

    def create_params
     @create_params ||= template.create_params(params)
    end

    def mass_assignable_params
      klass = template.klass
      params = {}
      create_params.each do |key,value|
        if !klass.accessible_attributes.blank?
          if klass.accessible_attributes.include?(key)
            params[key] = value
          end
        else
          if !klass.protected_attributes.include?(key)
            params[key] = value
          end
        end
      end
      params
    end

    def set_protected_attributes
      parameter_keys = create_params.keys
      protected_keys = Set.new
      klass = template.klass

      if klass.respond_to?(:accessible_attributes) && !klass.accessible_attributes.blank?
        protected_keys += parameter_keys - klass.accessible_attributes.to_a.map(&:to_sym)
      end

      if klass.respond_to?(:protected_attributes) && !klass.protected_attributes.blank?
        protected_keys += parameter_keys & klass.protected_attributes.to_a.map(&:to_sym)
      end

      protected_keys.each do |key|
        instance.send("#{key}=", create_params[key]) if instance.respond_to?("#{key}=")
      end
    end
  end
end
