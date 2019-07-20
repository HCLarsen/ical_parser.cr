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
end
