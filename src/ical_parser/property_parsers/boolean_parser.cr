module IcalParser
  module BooleanParser
    def self.parse(string)
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
