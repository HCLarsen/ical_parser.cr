module IcalParser
  class TimeParser < ValueParser
    TIME = Time::Format.new("%H%M%S")
    
    def parse(string : String)
      Time.parse(string, TIME.pattern)
    end
  end
end
