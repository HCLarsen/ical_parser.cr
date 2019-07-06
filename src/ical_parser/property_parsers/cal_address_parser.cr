require "uri"

module IcalParser
  @@caladdress_parser = Proc(String, String).new do |value|
    value
  end
end
