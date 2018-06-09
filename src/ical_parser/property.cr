module IcalParser
  class Property(T)
    getter name : String

    def initialize(@name : String, @parser : ValueParser(T))
    end

    def parse(params : String, value : String) : T
      params_hash = parse_params(params)
      @parser.parse(value, params_hash)
    end

    def get(eventc : String) : T
      regex = /#{@name}(?<params>;.+?)?:(?<value>.+?)\R/i
      matches = eventc.scan(regex)
      if matches.size == 1
        @parser.parse(matches.first["value"])
      elsif matches.size > 1
        raise "Invalid Event: #{@name} MUST NOT occur more than once"
      else
        raise "Invalid Event: #{@name} is REQUIRED"
      end
    end

    def parse_params(params : String) : Hash(String, String)
      return Hash(String, String).new if params.empty?

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
