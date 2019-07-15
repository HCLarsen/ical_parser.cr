require "uri"
require "./../cal_address"

module IcalParser
  @@caladdress_parser = Proc(String, Hash(String, String), String).new do |value, params|
    output = {"uri" => value} of String => JSON::Any::Type

    params.each do | k, v |
      key = k.downcase
      if ["member", "delegated-to", "delegated-from"].includes?(key)
        values = v.split(',')
        output[key] = values.map do |e|
          hash = {"uri" => JSON::Any.new(e.strip('"'))}
          JSON::Any.new(hash)
        end
      elsif key == "sent-by"
        output[key] = {"uri" => JSON::Any.new(v)}
      elsif key == "rsvp"
        output[key] = (v == "TRUE")
      elsif key == "dir"
        output[key] = v.strip('"')
      else
        output[key] = v
      end
    end

    output.to_json
  end
end
