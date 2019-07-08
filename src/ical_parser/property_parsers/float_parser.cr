require "json"

module IcalParser
  @@float_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.to_f.to_json
  end
end
