module IcalParser
  @@duration_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if value.match(DUR_DATE_REGEX) || value.match(DUR_WEEKS_REGEX)
      value
    else
      raise "Invalid Duration format"
    end
  end
end
