module IcalParser
  class Property(T)
    property parser : ValueParser(T)
    getter quantity : Quantity

    enum Quantity
      One
      Two
      List
    end

    def initialize(@parser : ValueParser(T), @quantity = Quantity::One)
    end

    def parse(value : String, params : String?) : T
      params ||= ""
      params_hash = parse_params(params)
      parsed = @parser.parse(value, params_hash)
    end

    def parse_params(params : String) : Hash(String, String)
      return Hash(String, String).new if params.empty?

      params = params.lstrip(';')
      array = params.split(";").map do |item|
        pair = item.split("=")
        if pair.size == 2
          pair
        else
          raise "Invaild parameters format"
        end
      end
      array = array.transpose
      Hash.zip(array.first, array.last)
    end
  end
end
