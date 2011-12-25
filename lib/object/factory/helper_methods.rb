class Object
  class Factory
    module HelperMethods

      module ClassMethods
        def factory
          Object::Factory.instance
        end
      end

      def self.included klass
        klass.extend ClassMethods
      end

      def a *args
        Object.factory.create_a *args
      end
      alias an a

      def a_saved *args
        Object.factory.create_and_save_a *args
      end

      def a_number *args
        Object.factory.a_number *args
      end

      def when_creating_a *args
        Object.factory.when_creating_a *args
      end
      alias when_creating_an when_creating_a

    end
  end
end
