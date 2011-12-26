module ObjectFactory
  class Factory
    class TemplateCollection < SimpleDelegator
      def initialize
        __setobj__(Set.new)
      end

      # Returns a Template object for the klass you're looking up.
      # If there isn't one defined, it creates one on the fly for you, but doesn't
      # store it in the template collection
      #
      # @return Object::Factory::Template
      def template_for klass
        find {|t| t.klass == klass } || Template.new(:klass => klass)
      end

      # Returns all the classes to delete records for when Factory#clean_up is invoked
      # Only returns those that respond to the right methods
      #
      # @return Array
      def classes_for_cleaning
        __getobj__.to_a.select do |t|
          t.clean_up && t.klass.respond_to?(:with_exclusive_scope) && t.klass.respond_to?(:delete_all)
        end.map(&:klass)
      end

    end
  end
end
