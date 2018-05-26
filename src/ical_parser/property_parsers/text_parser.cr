module IcalParser
  module TextParser
    def self.parse(string)
      string.gsub(/(\\(?!\\))/){ |match| "" }
    end

    def self.generate(string)
      string.gsub(/(\,|\;|\\[^n])/){ |match| "\\" + match }
    end
  end
end
