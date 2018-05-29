require "./value_parser"

module IcalParser
  class DateParser < ValueParser
    def parse(string : String) : Time
      year = /(\d{4})/.match(string).try &.[1].to_i || 0
      month = /\d{4}(\d{2})/.match(string).try &.[1].to_i || 0
      day = /\d{6}(\d{2})/.match(string).try &.[1].to_i || 0
      Time.new(year, month, day)
    end
  end
end
