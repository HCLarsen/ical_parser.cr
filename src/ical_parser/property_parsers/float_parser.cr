module IcalParser
  class FloatParser < ValueParser
    def parse(string : String)
      string.to_f
    end
  end
end
