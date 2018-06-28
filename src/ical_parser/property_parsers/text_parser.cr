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
    def parse(string : String, params = {} of String => String, options = {} of String => Bool) : T
      string.gsub(/(\\(?!\\))/) { |match| "" }
    end

    def generate(string : String) : String
      string.gsub(/(\,|\;|\\[^n])/) { |match| "\\" + match }
    end
  end
end
