require "./common"

class ICal::Event
  getter summary : String
  getter uid : String
  getter dtstart : Time
  getter dtend : Time
  getter description : String?
  getter location : String?
  getter url : String?

  def initialize(vevent : String)
    summaryRegex = /SUMMARY:(.*)\R/
    uidRegex = /UID:(.*)\R/

    descriptionRegex = /(?s)DESCRIPTION:(.*?)\R\w/
    locationRegex = /(?<=LOCATION:)(.*)\R/
    urlRegex = /URL:(.*)\R/

    startRegex = /DTSTART.*:(.*)\R/
    endRegex = /DTEND.*:(.*)\R/
    durationRegex = /DURATION.*:(.*)\R/

    @summary = summaryRegex.match(vevent).try &.[1].strip || ""
    @uid = uidRegex.match(vevent).try &.[1].strip || ""
    @location = locationRegex.match(vevent).try &.[1].strip

    if startString = startRegex.match(vevent)
      @dtstart = ICal.from_iCalDT(startString[1].strip)
    else
      raise "Invalid Event: No start time found"
    end

    if endString = endRegex.match(vevent)
      @dtend = ICal.from_iCalDT(endString[1].strip)
    elsif durationString = durationRegex.match(vevent)
      duration = ICal.duration(durationString[1].strip)
      @dtend = @dtstart + duration
    else
      # For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE value type but no "DTEND" nor "DURATION" property, the event's duration is taken to be one day.  For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE-TIME value type but no "DTEND" property, the event ends on the same calendar date and time of day specified by the "DTSTART" property.
      raise "No End Time or Duration Found"
    end

    if descriptionString = descriptionRegex.match(vevent)
      @description = ICal.rfc5545_text_unescape(descriptionString[1].strip)
    end

    @url = urlRegex.match(vevent).try &.[1].strip || nil
  end
end
