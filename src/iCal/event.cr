require "./common"

class ICal::Event
  getter summary : String
  getter uid : String
  getter dtstart : Time
  getter dtend : Time
  getter description : String?
  getter location : String?
  getter url : String?

  def initialize(eventProp : String)
    urlRegex = /URL:(.*)\R/
    endRegex = /DTEND.*:(.*)\R/
    durationRegex = /DURATION.*:(.*)\R/

    @summary = extract_text("SUMMARY", eventProp)
    @uid = extract_text("UID", eventProp)

    @description = extract_optional_text("DESCRIPTION", eventProp)
    @location = extract_optional_text("LOCATION", eventProp)

    @dtstart = extract_date_time("DTSTART", eventProp)

    if endString = endRegex.match(eventProp)
      @dtend = extract_date_time("DTEND", eventProp)
    elsif durationString = durationRegex.match(eventProp)
      duration = extract_duration(eventProp)
      @dtend = @dtstart + duration
    else
      # For cases where a "eventProp" calendar component specifies a "DTSTART" property with a DATE value type but no "DTEND" nor "DURATION" property, the event's duration is taken to be one day.  For cases where a "eventProp" calendar component specifies a "DTSTART" property with a DATE-TIME value type but no "DTEND" property, the event ends on the same calendar date and time of day specified by the "DTSTART" property.
      raise "No End Time or Duration Found"
    end

    @url = urlRegex.match(eventProp).try &.[1].strip || nil
  end

  private def extract_date_time(propName, eventProp) : Time
    regex = /#{propName}.*:(.*)\R/

    if string = regex.match(eventProp)
      ICal.from_iCalDT(string[1].strip)
    else
      raise "Invalid Event: No #{propName} present"
    end
  end

  private def extract_duration(eventProp) : Time::Span
    regex = /DURATION.*:(.*)\R/

    if string = regex.match(eventProp)
      ICal.duration(string[1].strip)
    else
      raise "No duration found"
    end
  end

  private def extract_text(propName, eventProp) : String
    regex = /(?s)#{propName}:(.*?)\R\w/

    if string = regex.match(eventProp)
      ICal.rfc5545_text_unescape(string[1].strip)
    else
      raise "Invalid Event: No #{propName} present"
    end
  end

  private def extract_optional_text(propName, eventProp) : String?
    regex = /(?s)#{propName}:(.*?)\R\w/

    if string = regex.match(eventProp)
      ICal.rfc5545_text_unescape(string[1].strip)
    end
  end
end
