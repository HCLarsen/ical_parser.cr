require "./value_parser"

module IcalParser
  @@boolean_parser = Proc(String, Hash(String, String), Bool).new do |value, params|
    if value == "TRUE"
      true
    elsif value == "FALSE"
      false
    else
      raise "Invalid Boolean value"
    end
  end
end
