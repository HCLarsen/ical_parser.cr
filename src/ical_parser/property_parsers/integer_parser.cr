module IcalParser
  @@integer_parser = Proc(String, Hash(String, String), Int32).new do |value, params|
    value.to_i
  end
end
