require "uri"

require "./value_parser"

module IcalParser
  @@uri_parser = Proc(String, Hash(String, String), URI).new do |value, params|
    URI.parse(value)
  end
end
