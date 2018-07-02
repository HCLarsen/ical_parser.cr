module IcalParser
  class FloatParser < ValueParser(Float64)
    def parse(string : String, params = {} of String => String) : T
      string.to_f
    end
  end
end
