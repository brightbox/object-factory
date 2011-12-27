module ObjectFactory
  # A simple class that generates unique values
  class ValueGenerator
    def initialize
      @counter = 0
    end

    def unique_integer
      @counter += 1
    end
    alias next_number unique_integer
    alias a_number unique_integer

    def value_for klass, field
      "#{klass.name.to_s}-#{field.to_s}-#{unique_integer}"
    end

  end
end
