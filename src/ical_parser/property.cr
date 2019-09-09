require "./common"

module IcalParser
  class Property
    getter name : String
    @types : Array(String)
    @parser : ParserType
    @key : String?
    getter list : Bool
    getter only_once = true

    def initialize(prop : NamedTuple)
      if prop[:name]?
        @name = prop[:name]? || ""
        component_property = COMPONENT_PROPERTIES[@name]

        @types = component_property[:types]
        if @types.size < 1
          raise "Property Error: Property must have at least ONE value type"
        end

        @parser = PARSERS[@types[0]]
        @list = component_property[:list]? || false

        @parts = prop[:parts]? || ["value"]
        @key = prop[:key]?

        if !prop[:only_once]? && prop.has_key? :only_once
          @only_once = false
        end
      else
        raise "Property Error: Property must have a name"
      end
    end

    def key : String
      @key || @name
    end

    def parse(value : String, params : String?) : String
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

    private def parse_value(value : String, params : Hash(String, String)) : String
      set_parser(params["VALUE"]?)

      if !@list
        if @only_once && @parts.size == 1
          parse_single_value(value, params)
        elsif @parts.size > 1
          parse_multi_part(value, params)
        else
          %([#{parse_single_value(value, params)}])
        end
      else
        parse_list(value, params)
      end
    end

    private def parse_multi_part(list : String, params : Hash(String, String)) : String
      semicolon_separator = /(?<!\\);/

      values = list.split(semicolon_separator)
      parts = @parts.map_with_index do |e, i|
        parsed = parse_single_value(values[i], params)
        %("#{e}":#{parsed})
      end
      %({#{parts.join(",")}})
    end

    private def parse_list(list : String, params : Hash(String, String)) : String
      comma_separator = /(?<!\\),/

      values = list.split(comma_separator)
      values.map! { |e| parse_single_value(e, params) }
      %([#{values.join(",")}])
    end

    private def parse_single_value(value : String, params : Hash(String, String)) : String
      @parser.call(value, params)
    end

    private def set_parser(value_type : String?)
      if value_type
        if @types.includes?(value_type)
          @parser = PARSERS[value_type]
        else
          raise "Invalid value type for this property"
        end
      else
       @parser = PARSERS[@types[0]]
     end
    end
  end
end
