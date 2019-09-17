require "./property_parsers/*"

module IcalParser
  FLOATING_DATE_TIME = Time::Format.new("%Y%m%dT%H%M%S")
  UTC_DATE_TIME      = Time::Format.new("%Y%m%dT%H%M%SZ")
  ZONED_DATE_TIME    = Time::Format.new("%Y%m%dT%H%M%S")

  DATE     = Time::Format.new("%Y%m%d")
  TIME     = Time::Format.new("%H%M%S")
  UTC_TIME = Time::Format.new("%H%M%SZ")

  DATE_REGEX = /^\d{8}$/
  DT_FLOATING_REGEX = /^\d{8}T\d{6}$/
  DT_UTC_REGEX      = /^\d{8}T\d{6}Z/
  DT_TZ_REGEX       = /(?<=\w:)\d{8}T\d{6}/
  TIME_FLOATING_REGEX = /^\d{6}$/
  TIME_UTC_REGEX = /^\d{6}Z$/

  DUR_DATE_REGEX  = /^(?<polarity>[+-])?P((?<days>\d+)D)?(T((?<hours>\d+)H)?((?<minutes>\d+)M)?((?<seconds>\d+)S)?)?$/
  DUR_WEEKS_REGEX = /^(?<polarity>[+-])?P(?<weeks>\d+)W$/

  alias ParserType = Proc(String, Hash(String, String), String)

  CLASSES = {
    "BOOLEAN"     => Bool,
    "CAL-ADDRESS" => CalAddress,
    "DATE"        => Time,
    "DATE-TIME"   => Time,
    "DURATION"    => Duration,
    "FLOAT"       => Float64,
    "INTEGER"     => Int32,
    "PERIOD"      => PeriodOfTime,
    "RECUR"       => RecurrenceRule,
    "TEXT"        => String,
    "TIME"        => Time,
    "URI"         => URI,
  }

  PARSERS = {
    "BINARY"      => @@text_parser,  # To be replaced with BinaryParser once written.
    "BOOLEAN"     => @@boolean_parser,
    "CAL-ADDRESS" => @@caladdress_parser,
    "DATE"        => @@date_parser,
    "DATE-TIME"   => @@date_time_parser,
    "DURATION"    => @@duration_parser,
    "FLOAT"       => @@float_parser,
    "INTEGER"     => @@integer_parser,
    "PERIOD"      => @@period_parser,
    "RECUR"       => @@recurrence_parser,
    "TEXT"        => @@text_parser,
    "TIME"        => @@time_parser,
    "URI"         => @@uri_parser,
    "UTC-OFFSET"  => @@text_parser,  # To be replaced with UTCOffsetParser once written.
  }

  COMPONENT_PROPERTIES = {
    prodid: {types: ["TEXT"]},
    version: {types: ["TEXT"]},
    method: {types: ["TEXT"]},
    calscale: {types: ["TEXT"]},
    uid: {types: ["TEXT"]},
    dtstamp: {types: ["DATE-TIME"], converter: Time::ISO8601Converter},
    created: {types: ["DATE-TIME"], converter: Time::ISO8601Converter},
    last_modified: {types: ["DATE-TIME"], converter: Time::ISO8601Converter},
    dtstart: {types: ["DATE-TIME", "DATE"], converter: Time::ISO8601Converter},
    dtend: {types: ["DATE-TIME", "DATE"], converter: Time::ISO8601Converter},
    duration: {types: ["DURATION"]},
    summary: {types: ["TEXT"]},
    classification: {types: ["TEXT"], default: "public"},
    categories: {types: ["TEXT"], list: true},
    resources: {types: ["TEXT"], list: true},
    contact: {types: ["TEXT"]},
    related_to: {types: ["TEXT"], getter: false},
    request_status: {types: ["TEXT"], getter: false},
    transp: {types: ["TEXT"], default: "opaque"},
    description: {types: ["TEXT"]},
    status: {types: ["TEXT"]},
    comment: {types: ["TEXT"]},
    location: {types: ["TEXT"]},
    priority: {types: ["INTEGER"]},
    sequence: {types: ["INTEGER"]},
    organizer: {types: ["CAL-ADDRESS"]},
    attendee: {types: ["CAL-ADDRESS"]},
    geo: {types: ["FLOAT"], parts: ["lat", "lon"]},
    rrule: {types: ["RECUR"]},
    exdate: {types: ["DATE-TIME", "DATE"], list: true, converter: JSON::ArrayConverter(Time::ISO8601Converter)},
    rdate: {types: ["DATE-TIME", "DATE", "PERIOD"], list: true, converter: JSON::ArrayConverter(Time::ISO8601Converter)},
    url: {types: ["URI"], converter: URI::URIConverter},
    all_day: {types: ["BOOLEAN"]}
  }
end
