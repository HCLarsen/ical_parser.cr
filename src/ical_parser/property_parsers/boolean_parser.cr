module IcalParser
  @@boolean_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if value == "TRUE"
      true.to_json
    elsif value == "FALSE"
      false.to_json
    else
      raise "Invalid Boolean value"
    end
  end
end
