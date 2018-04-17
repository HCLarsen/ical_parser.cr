require "./common"

class ICal::Event
  getter summary : String
  getter uid : String
  getter dtstart : Time
  getter dtend : Time?
  getter description : String?
  getter location : String?
  getter url : String?

  getter allDay = false

  def initialize(eventProp : String)
    @summary = extract_text("SUMMARY", eventProp)
    @uid = extract_text("UID", eventProp)

    @description = extract_optional_text("DESCRIPTION", eventProp)
    @location = extract_optional_text("LOCATION", eventProp)

    @dtstart = extract_date_or_date_time("DTSTART", eventProp)
    @dtend = find_end_time(eventProp)

    @url = extract_uri(eventProp)
  end

  private def find_end_time(eventProp : String) : Time
    endRegex = /DTEND.*:(.*)\R/
    durationRegex = /DURATION.*:(.*)\R/

    if endString = endRegex.match(eventProp)
      @dtend = extract_date_or_date_time("DTEND", eventProp)
    elsif durationString = durationRegex.match(eventProp)
      duration = extract_duration(eventProp)
      @dtend = @dtstart + duration
    else
      @dtend = @dtstart
    end
  end

  private def extract_date_or_date_time(propName : String, eventProp : String) : Time
    regex = /#{propName}.*:(.*)\R/

    dtRegex = /\d{8}T\d{6}/
    dateRegex = /\d{8}/

    if string = regex.match(eventProp)
      if string[1].match(dtRegex)
        ICal.from_iCalDT(string[1].strip)
      else
        @allDay = true
        ICal.from_iCalDate(string[1].strip)
      end
    else
      raise "Invalid Event: No #{propName} present"
    end
  end

  private def extract_date_time(propName : String, eventProp : String) : Time
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

  private def extract_text(propName : String, eventProp : String) : String
    regex = /(?s)#{propName}:(.*?)\R(?=\w)/
    matches = eventProp.scan(regex)

    if matches.size == 1
      ICal.rfc5545_text_unescape(matches[0][1].strip)
    elsif matches.size > 1
      raise "Invalid Event: #{propName.upcase} MUST NOT occur more than once"
    else
      raise "Invalid Event: No #{propName} present"
    end
  end

  private def extract_optional_text(propName : String, eventProp : String) : String?
    regex = /(?s)#{propName}:(.*?)\R\w/
    matches = eventProp.scan(regex)

    if matches.size == 1
      ICal.rfc5545_text_unescape(matches[0][1].strip)
    end
  end

  private def extract_uri(eventProp) : String?
    regex = /URL:(.*)\R/
    matches = eventProp.scan(regex)

    if matches.size == 1
      ICal.rfc5545_text_unescape(matches[0][1].strip)
    end
  end
end
