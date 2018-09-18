module IcalParser
  class IntegerParser < ValueParser(Int32)
    def parse(string : String, params = {} of String => String) : T
      string.to_i
    end
  end

  @@integer_parser = Proc(String, Hash(String, String), Int32).new do |value, params|
    value.to_i
  end
end
