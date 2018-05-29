require "./value_parser"

module IcalParser
  class BooleanParser < ValueParser
    def parse(string : String) : Bool
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
