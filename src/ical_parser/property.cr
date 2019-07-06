module IcalParser
  class Property(T)
    @parser : ParserType
    @alt_values : Array(String)
    getter single_value : Bool
    getter only_once : Bool

    def initialize(@parser : ParserType, *, @alt_values = [] of String, @parts = ["value"], @only_once = true, @single_value = true)
    end

    def parse(value : String, params : String?) : Hash(String, JSON::Any)
      output = Hash(String, JSON::Any).new

      params ||= ""
      params_hash = parse_params(params)

      output["params"] = JSON::Any.new(params_hash)
      output["value"] = parse_value(value, params_hash)
      output
    end

    def parse_params(params : String) : Hash(String, JSON::Any)
      output = Hash(String, JSON::Any).new
      return output if params.empty?

      params = params.lstrip(';')

      array = params.split(";").map do |item|
        pair = item.split("=")
        if pair.size == 2
          output[pair.first] = JSON::Any.new(pair.last)
        else
          raise "Invaild parameters format"
        end
      end

      output
    end

    def parse_value(value : String, params : Hash(String, JSON::Any)) : JSON::Any
      # new_params = Hash(String, String).new

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
          parsed = parser.call(value).as T
          JSON::Any.new(parsed)
        elsif @parts.size > 1
          values = value.split(/(?<!\\);/)
          parts = values.map { |e| JSON::Any.new(parser.call(e).as T) }
          JSON::Any.new(Hash.zip(@parts, parts))
        else
          # [parser.call(value, new_params).as T].as Array(T)
          raise "Error"
        end
      else
        values = value.split(/(?<!\\),/)
        values = values.map { |e| JSON::Any.new(parser.call(e).as T) }
        JSON::Any.new(values)
      end
    end
  end
end
