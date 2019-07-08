require "json"

module IcalParser
  @@integer_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.to_i.to_json
  end
end
