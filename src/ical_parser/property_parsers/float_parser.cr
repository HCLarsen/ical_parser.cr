module IcalParser
  class FloatParser < ValueParser(Float64)
    def parse(string : String, params = {} of String => String) : T
      string.to_f
    end
  end

  @@float_parser = Proc(String, Hash(String, String), Float64).new do |value, params|
    value.to_f
  end
end
