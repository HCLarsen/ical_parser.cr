require "json"

module IcalParser
  # Parses a TEXT property into a String object, removing escape characters.
  @@text_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.gsub(/\\(?![nN\\])/) { |match| "" }.to_json
  end

  # Converts a String object into a TEXT property, adding escape characters as needed.
  @@text_generator = Proc(String, String).new do |value|
    value.gsub(/(\,|\;|\\[^n])/) { |match| "\\" + match }
  end
end
