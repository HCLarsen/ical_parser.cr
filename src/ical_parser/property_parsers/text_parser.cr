require "./value_parser"

module IcalParser
  # The TextParser singleton class parses the RFC5545 [Text](https://tools.ietf.org/html/rfc5545#section-3.3.11) value type
  #
  # As a singleton class, typical instantiation will result in a compile
  # time error.
  #
  # ```
  # TextParser.new # => private method 'new' called for IcalParser::TextParser:Class
  # ```
  #
  # Instead, access the singleton instance by calling #parser on the class.
  #
  # ```
  # parser = TextParser.parser # => #<IcalParser::TextParser:0x1062d0f60>
  # ```
  #
  class TextParser < ValueParser(String)
    def parse(string : String, params = {} of String => String) : T
      string.gsub(/\\(?![nN\\])/) { |match| "" }
    end

    def generate(string : String) : String
      string.gsub(/(\,|\;|\\[^n])/) { |match| "\\" + match }
    end
  end

  # Parses a TEXT property into a String object, removing escape characters.
  @@text_parser = Proc(String, Hash(String, String), String).new do |value, params|
    value.gsub(/\\(?![nN\\])/) { |match| "" }
  end

  # Converts a String object into a TEXT property, adding escape characters as needed.
  @@text_generator = Proc(String, String).new do |value|
    value.gsub(/(\,|\;|\\[^n])/) { |match| "\\" + match }
  end
end
