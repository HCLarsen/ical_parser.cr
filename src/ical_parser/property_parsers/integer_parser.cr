module IcalParser
  @@integer_parser = Proc(String, Int32).new do |value|
    value.to_i
  end
end
