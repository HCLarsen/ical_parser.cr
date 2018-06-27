module IcalParser
  FLOATING_TIME = Time::Format.new("%Y%m%dT%H%M%S")
  UTC_TIME      = Time::Format.new("%Y%m%dT%H%M%SZ")
  ZONED_TIME    = Time::Format.new("%Y%m%dT%H%M%S")

  DATE_REGEX        = /^;VALUE=DATE:\d{8}/
  DT_FLOATING_REGEX = /^\d{8}T\d{6}(?!Z)/
  DT_UTC_REGEX      = /^\d{8}T\d{6}Z/
  DT_TZ_REGEX       = /(?<=\w:)\d{8}T\d{6}/
end
