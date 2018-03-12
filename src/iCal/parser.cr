class ICal::Parser
  FLOATING_TIME = Time::Format.new("%Y%m%dT%H%M%S")
  UTC_TIME = Time::Format.new("%Y%m%dT%H%M%SZ")
  ZONED_TIME = Time::Format.new("%Y%m%dT%H%M%S")

  def parse_events(filename : String)
  end

  def self.rfc5545_text_escape(string)
    string.gsub(/(\,|\;|\\[^n])/){ |match| "\\" + match }
  end

  def self.rfc5545_text_unescape(string)
    string.gsub(/(\\(?!\\))/){ |match| "" }
  end

  def self.duration(string)
    days = (/(\d+)(?=W)/.match(string).try &.[1].to_i || 0) * 7
    days += /(\d+)(?=D)/.match(string).try &.[1].to_i || 0
    hours = /(\d+)(?=H)/.match(string).try &.[1].to_i || 0
    minutes = /(\d+)(?=M)/.match(string).try &.[1].to_i || 0
    seconds = /(\d+)(?=S)/.match(string).try &.[1].to_i || 0

    Time::Span.new(days, hours, minutes, seconds)
  end

  def self.from_iCalDT(string) : Time
    dTRegex = /^\d{8}T\d{6}(?!Z)/
    dTUTCRegex = /^\d{8}T\d{6}Z/
    dTTZRegex = /(?<=\w:)\d{8}T\d{6}/

    if dTRegex.match(string)
      Time.parse(string, FLOATING_TIME.pattern, Time::Kind::Local)
    elsif dTUTCRegex.match(string)
      Time.parse(string, UTC_TIME.pattern, Time::Kind::Utc)
    elsif dTTZRegex.match(string)
      # Always matches a zoned time to local time. This will likely cover >90% of applications,
      # however, I will eventually need to include proper time zone parsing and usage. I may create
      # a time zone gem similar to Ruby's tzinfo.
      timeString = (dTTZRegex.match(string) || ["0"])[0]
      Time.parse(timeString, ZONED_TIME.pattern, Time::Kind::Local)
    else
      raise "Invalid Time Format"
    end
  end
end
