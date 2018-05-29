module IcalParser
  class BooleanParser
    @@instance : BooleanParser?

    private def initialize; end

    def self.parser : BooleanParser
      if @@instance.nil?
      	@@instance = new
      else
        @@instance.not_nil!
  	  end
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end

    def parse(string) : Bool
      if string == "TRUE"
        true
      elsif string == "FALSE"
        false
      else
        raise "Invalid Boolean value"
      end
    end
  end
end
