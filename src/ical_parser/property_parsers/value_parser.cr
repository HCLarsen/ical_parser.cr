module IcalParser
  abstract class ValueParser(T)
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

    abstract def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) forall T
  end
end
