module IcalParser
  class Property(T)
    property parser : ValueParser(T)
    getter single_value : Bool
    getter only_once : Bool

    def initialize(@parser : ValueParser(T), *, @only_once = true, @single_value = true)
    end

    def parse(value : String, params : String?) forall T
      params ||= ""
      params_hash = parse_params(params)

      if @single_value
        if @only_once
          @parser.parse(value, params_hash)
        else
          [@parser.parse(value, params_hash)]
        end
      else
        values = value.split(/(?<!\\),/)
        values.map { |e| @parser.parse(e, params_hash) }
      end
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
