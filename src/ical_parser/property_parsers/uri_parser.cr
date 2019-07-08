require "json"
require "uri"

require "./value_parser"

module IcalParser
  @@uri_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.to_json
  end
end
