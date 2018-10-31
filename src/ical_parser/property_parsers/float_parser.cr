module IcalParser
  @@float_parser = Proc(String, Hash(String, String), Float64).new do |value, params|
    value.to_f
  end
end
