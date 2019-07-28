require "json"
require "uri"

module IcalParser
  @@uri_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.to_json
  end
end
