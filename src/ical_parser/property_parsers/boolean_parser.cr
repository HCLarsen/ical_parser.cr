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

  @@boolean_parser = Proc(String, Hash(String, String), Bool).new do |value, params|
    if value == "TRUE"
      true
    elsif value == "FALSE"
      false
    else
      raise "Invalid Boolean value"
    end
  end
end
