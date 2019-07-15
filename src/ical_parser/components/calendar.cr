module IcalParser
  class Calendar
    PROPERTIES = {
      "prodid"    => String,
      "version"   => String,
      "method"    => String,
      "calscale"  => String
    }

    property prodid : String
    property version = "2.0"
    property method : String?
    property calscale : String?
    property events = [] of Event

    def initialize(@prodid : String, @events = [] of Event)
    end

    private macro assign_vars
      {% for key, value in PROPERTIES %}
        @{{key.id}} = properties[{{key}}].as {{value.id}} if properties[{{key}}]?
      {% end %}
    end
  end
end
