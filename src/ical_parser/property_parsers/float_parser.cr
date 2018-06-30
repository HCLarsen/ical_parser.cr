module IcalParser
  class FloatParser < ValueParser(Float64)
    def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) : T
      string.to_f
    end
  end
end
