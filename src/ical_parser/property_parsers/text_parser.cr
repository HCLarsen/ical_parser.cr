require "./value_parser"

module IcalParser
  class TextParser < ValueParser(String)
    def parse(string : String, params = {} of String => String) : T
      string.gsub(/(\\(?!\\))/){ |match| "" }
    end

    def generate(string : String) : String
      string.gsub(/(\,|\;|\\[^n])/){ |match| "\\" + match }
    end
  end
end
