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

  def self.from_iCalDT(string)
    dTRegex = /^\d{8}T\d{6}(?!Z)/
    dTUTCRegex = /^\d{8}T\d{6}Z/
    dTTZRegex = /\w:\d{8}T\d{6}/

    if dTUTCRegex.match(string)
      Time.parse(string, UTC_TIME.pattern, Time::Kind::Utc)
    elsif dTRegex.match(string)
      Time.parse(string, FLOATING_TIME.pattern, Time::Kind::Local)
    else
      raise "Invalid Time Format"
    end
  end
end
