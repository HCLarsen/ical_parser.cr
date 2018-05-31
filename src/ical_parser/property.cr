module IcalParser
  class Property
    getter name : String

    def initialize(@name : String, @parser : ValueParser)
    end

    def get(eventc : String)
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

    def parse_params(params : String)
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
