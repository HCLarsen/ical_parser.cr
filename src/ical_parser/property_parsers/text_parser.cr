require "./value_parser"

module IcalParser
  class TextParser < ValueParser
    def parse(string : String) : String
      string.gsub(/(\\(?!\\))/){ |match| "" }
    end

    def generate(string : String) : String
      string.gsub(/(\,|\;|\\[^n])/){ |match| "\\" + match }
    end
  end
end
