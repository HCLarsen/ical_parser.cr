module IcalParser
  abstract class ValueParser
    private def initialize; end

    macro inherited
      def self.parser : {{ @type }}
        if @@instance.nil?
        	@@instance = new
        else
          @@instance.not_nil!
    	  end
      end
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end

    abstract def parse(string : String)
  end
end
