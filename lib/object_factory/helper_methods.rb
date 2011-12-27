module ObjectFactory
  module HelperMethods

    module ClassMethods
      def factory
        ObjectFactory::Factory.instance
      end
    end

    def self.included klass
      klass.extend ClassMethods
    end

    # Define the helper methods this way because I'm lazy and they all just proxy forward
    # to Object.factory anyway. Handles blocks being passed through, and optimises the methods
    # if no block is passed.
    {
      :a => :create_a,
      :an => :create_a,
      :a_saved => :create_and_save_a,
      :a_number => :a_number,
      :when_creating_a => :when_creating_a,
      :when_creating_an => :when_creating_a
    }.each do |source, destination|
      class_eval <<-EOF
        def #{source} *args
          # Possibly an optimisation too far, but oh well. Doesn't pass block through if none
          # is given to the top method.
          if block_given?
            block = Proc.new
            Object.factory.#{destination} *args, &block
          else
            Object.factory.#{destination} *args
          end
        end
      EOF
    end

  end
end

Object.__send__ :include, ObjectFactory::HelperMethods
