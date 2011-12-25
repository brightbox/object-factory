class Object
  class Factory
    class TemplateCollection < SimpleDelegator
      def initialize
        __setobj__(Set.new)
      end

      # Returns a Template object for the klass you're looking up.
      # If there isn't one defined, it creates one on the fly for you, but doesn't
      # store it in the template collection
      #
      # @return [Object::Factory::Template]
      def template_for klass
        find {|t| t.klass == klass } || Template.new(:klass => klass)
      end
    end
  end
end
