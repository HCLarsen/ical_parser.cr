require "uri"

module IcalParser
  @@caladdress_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value
  end
end
