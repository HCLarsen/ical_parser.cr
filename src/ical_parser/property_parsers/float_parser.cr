module IcalParser
  @@float_parser = Proc(String, Float64).new do |value|
    value.to_f
  end
end
