module IcalParser
  class EventParser
    private def initialize; end

    def self.parser : EventParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(eventc : String)
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/
      lines = eventc.lines
      lines.each do |line|
        if match = line.match(regex)
          if (name = match["name"]?) && (value = match["value"]?)
            puts "Match made for #{name}"
          end
        else
          raise "No match made for invalid line #{line}"
        end
      end
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
