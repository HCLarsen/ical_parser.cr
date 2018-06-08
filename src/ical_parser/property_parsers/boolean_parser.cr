require "./value_parser"

module IcalParser
  class BooleanParser < ValueParser(Bool)
    def parse(string : String, params = {} of String => String) : T
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
