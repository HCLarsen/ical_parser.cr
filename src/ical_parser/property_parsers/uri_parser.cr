require "uri"

require "./value_parser"

module IcalParser
  @@uri_parser = Proc(String, String).new do |value|
    value
  end
end
