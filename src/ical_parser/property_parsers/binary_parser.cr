module IcalParser
  @@binary_parser = Proc(String, Hash(String, String), String).new do |value, params|
    Base64.decode_string(value)
  end
end
