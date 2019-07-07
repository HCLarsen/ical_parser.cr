module IcalParser
  class Property(T)
    @parser : ParserType
    @alt_values : Array(String)
    getter single_value : Bool
    getter only_once : Bool

    def initialize(@parser : ParserType, *, @alt_values = [] of String, @parts = ["value"], @only_once = true, @single_value = true)
    end

    def parse(value : String, params : String?) : String
      params ||= ""
      params_hash = parse_params(params)

      parser = active_parser(params_hash)
      value_hash = parse_value(value, parser)

      %({"params":#{params_hash},"value":#{value_hash}})
    end

    def active_parser(params) : ParserType
      params = JSON.parse(params)

      if value_type = params["VALUE"]?
        if @alt_values.includes?(value_type)
          parser = PARSERS[value_type]
        else
          raise "Invalid value type for this property"
        end
      else
        parser = @parser
      end
    end

    def parse_params(params : String) : String
      output = Hash(String, String | Array(String)).new
      return output.to_json if params.empty?

      params = params.lstrip(';')

      array = params.split(";").map do |item|
        pair = item.split("=")
        if pair.size == 2
          if ["DELEGATED-TO", "DELEGATED-FROM", "MEMBER"].includes?(pair.first)
            output[pair.first] = pair.last.split(',').map(&.strip('"'))
          else
            output[pair.first] = pair.last
          end
        else
          raise "Invaild parameters format"
        end
      end

      output.to_json
    end

    def parse_value(value : String, parser : ParserType) : String
      if @single_value
        if @only_once && @parts.size == 1
          parsed = parser.call(value).as T
          parsed.to_json
        elsif @parts.size > 1
          values = value.split(/(?<!\\);/)
          parts = values.map { |e| JSON::Any.new(parser.call(e).as T) }
          Hash.zip(@parts, parts).to_json
        else
          # [parser.call(value, new_params).as T].as Array(T)
          raise "Error"
        end
      else
        values = value.split(/(?<!\\),/)
        values = values.map { |e| JSON::Any.new(parser.call(e).as T) }
        values.to_json
      end
    end
  end
end
