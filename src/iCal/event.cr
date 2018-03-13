require "./common"

class ICal::Event
  getter summary : String
  getter uid : String
  getter start : Time
  getter end : Time
  getter description : String?
  getter location : String?
  getter url : String?

  def initialize(vevent : String)
    summaryRegex = /(?<=SUMMARY:)(.*)(?=\n)/
    uidRegex = /(?<=UID:)(.*)(?=\n)/

    descriptionRegex = /(?s)(?<=DESCRIPTION:)(.*?)(?=\n\w)/
    locationRegex = /(?<=LOCATION:)(.*)(?=\n)/
    urlRegex = /(?<=URL:)(.*)(?=\n)/

    startRegex = /(?<=DTSTART).*:(.*)(?=\n)/
    endRegex = /(?<=DTEND).*:(.*)(?=\n)/
    durationRegex = /(?<=DURATION).*:(.*)(?=\n)/

    @summary = summaryRegex.match(vevent).try &.[1] || ""
    @uid = uidRegex.match(vevent).try &.[1] || ""
    startString = startRegex.match(vevent).try &.[1] || ""
    @start = ICal.from_iCalDT(startString)
    if endRegex.match(vevent)
      endString = endRegex.match(vevent).try &.[1] || ""
      @end = ICal.from_iCalDT(endString)
    elsif durationRegex.match(vevent)
      durationString = durationRegex.match(vevent).try &.[1] || ""
      duration = ICal.duration(durationString)
      @end = @start + duration
    else
      # For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE value type but no "DTEND" nor "DURATION" property, the event's duration is taken to be one day.  For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE-TIME value type but no "DTEND" property, the event ends on the same calendar date and time of day specified by the "DTSTART" property.
      raise "No End Time or Duration Found"
    end

    descriptionString = descriptionRegex.match(vevent).try &.[1] || nil
    if descriptionString
      @description = ICal.rfc5545_text_unescape(descriptionString)
    else
      @description = nil
    end

    @location = locationRegex.match(vevent).try &.[1] || nil
    @url = urlRegex.match(vevent).try &.[1] || nil
  end
end
