module IcalParser
  FLOATING_DATE_TIME = Time::Format.new("%Y%m%dT%H%M%S")
  UTC_DATE_TIME      = Time::Format.new("%Y%m%dT%H%M%SZ")
  ZONED_DATE_TIME    = Time::Format.new("%Y%m%dT%H%M%S")

  DATE     = Time::Format.new("%Y%m%d")
  TIME     = Time::Format.new("%H%M%S")
  UTC_TIME = Time::Format.new("%H%M%SZ")

  DATE_REGEX        = /^;VALUE=DATE:\d{8}/
  DT_FLOATING_REGEX = /^\d{8}T\d{6}(?!Z)/
  DT_UTC_REGEX      = /^\d{8}T\d{6}Z/
  DT_TZ_REGEX       = /(?<=\w:)\d{8}T\d{6}/
end
