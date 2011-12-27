module ObjectFactory
  class Template
    extend Forwardable
    def_delegator :generator, :value_for

    attr_accessor :klass, :generate, :set, :auto_generate, :auto_confirm, :generate_email_address, :generate_ip_address, :clean_up, :after_create

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

    def clean_up
      @clean_up = true if @clean_up.nil?
      @clean_up
    end

    EMAIL_ADDRESS_LAMBDA = lambda { 6.random_letters + '@' +  10.random_letters + '.com' }
    IP_ADDRESS_LAMBDA = lambda { Array.new(4) { 1.random_number(:to => 255) }.join(".") }

    # This includes both the :generate specified params, and :generate_email_address, etc ones
    def generated_params
      h = {}
      Array(generate_email_address).each do |field|
        h[field] = EMAIL_ADDRESS_LAMBDA
      end
      Array(generate_ip_address).each do |field|
        h[field] = IP_ADDRESS_LAMBDA
      end
      h = generate.merge(h)
      h.delete_if {|k,v| set.has_key?(k) }
    end

    # Figures out all the params required to be passed to the instance at create
    # time. bespoke_params are params passed when calling a(_saved)() and take priority
    # over those specified through the factory.
    def create_params bespoke_params={}
      bespoke_params ||= {}
      h = set.dup.merge(bespoke_params)
      generated_params.each do |k,blk|
        # Make sure we don't call the block if the param is going to be overridden anyway
        next if h.has_key?(k)
        h[k] = blk.call
      end
      h = auto_generated_params.merge(h)
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
