module IcalParser
  class IntegerParser < ValueParser(Int32)
    def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) : T
      string.to_i
    end
  end
end
