module IcalParser
  class Property(T)
    @parser : ParserType
    @alt_values : Array(String)
    getter single_value : Bool
    getter only_once : Bool

    def initialize(@parser : ParserType, *, @alt_values = [] of String, @parts = ["value"], @only_once = true, @single_value = true)
    end

    def parse(value : String, params : String?) forall T
      params ||= ""
      params_hash = parse_params(params)

      parse_value(value, params_hash)
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

    def parse_value(value : String, params : Hash(String, String)) : T | Array(T) | Hash(String, T)
      if value_type = params["VALUE"]?
        if @alt_values.includes?(value_type)
          parser = PARSERS[value_type]
        else
          raise "Invalid value type for this property"
        end
      else
        parser = @parser
      end
      if @single_value
        if @only_once && @parts.size == 1
          parser.call(value, params).as T
        elsif @parts.size > 1
          values = value.split(/(?<!\\);/)
          parts = values.map { |e| parser.call(e, params).as T }
          Hash.zip(@parts, parts)
        else
          [parser.call(value, params).as T].as Array(T)
        end
      else
        values = value.split(/(?<!\\),/)
        values.map { |e| parser.call(e, params).as T }. as Array(T)
      end
    end
  end
end
