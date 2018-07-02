module IcalParser
  class IntegerParser < ValueParser(Int32)
    def parse(string : String, params = {} of String => String) : T
      string.to_i
    end
  end
end
