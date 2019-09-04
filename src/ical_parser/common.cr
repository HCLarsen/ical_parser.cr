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
    uid: {types: ["TEXT"], required: true},
    dtstamp: {types: ["DATE-TIME"], required: true},
    created: {types: ["DATE-TIME"]},
    last_modified: {types: ["DATE-TIME"]},
    dtstart: {types: ["DATE-TIME", "DATE"], required: true},
    dtend: {types: ["DATE-TIME", "DATE"]},
    duration: {types: ["DURATION"]},
    summary: {types: ["TEXT"]},
    classification: {types: ["TEXT"], default: "public"},
    categories: {types: ["TEXT"], list: true},
    resources: {types: ["TEXT"], list: true},
    contact: {types: ["CAL-ADDRESS"]},
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
    geo: {types: ["FLOAT"]},
    rrule: {types: ["RECUR"]},
    exdate: {types: ["DATE-TIME", "DATE"], list: true},
    rdate: {types: ["DATE-TIME", "DATE", "PERIOD"], list: true},
    url: {types: ["URI"], converter: URI::URIConverter},
    all_day: {types: ["BOOLEAN"], key: "all-day"}
  }
end
