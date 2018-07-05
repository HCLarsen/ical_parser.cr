module IcalParser
  class Calendar
    property prodid : String
    property events = [] of Event

    def initialize(@prodid : String, @events = [] of Event)
    end
  end
end
