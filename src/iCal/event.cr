class ICal::Event
  getter summary : String
  getter uid : String
  getter start : Time
  getter description : String | Nil
  getter location : String | Nil

  def initialize(vevent : String)
    summaryRegex = /(?<=SUMMARY:)(.*)(?=\n)/
    uidRegex = /(?<=UID:)(.*)(?=\n)/
    descriptionRegex = /(?<=DESCRIPTION:)(.*)(?=\n)/

    stampRegex = /(?<=DTSTAMP).*:(.*)(?=\n)/
    startRegex = /(?<=DTSTART).*:(.*)(?=\n)/
    endRegex = /(?<=DTEND).*:(.*)(?=\n)/

    @summary = summaryRegex.match(vevent).try &.[1] || ""
    @uid = uidRegex.match(vevent).try &.[1] || ""
    startString = startRegex.match(vevent).try &.[1] || ""
    @start = Time.parse(startString, "%Y%m%dT%H%M%S")
  end
end
