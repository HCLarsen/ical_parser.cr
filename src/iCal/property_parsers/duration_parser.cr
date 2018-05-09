module ICal
  module DurationParser
    def self.parse(string)
      polarity = /^-/.match(string) ? -1 : 1

      days = (/(\d+)(?=W)/.match(string).try &.[1].to_i || 0) * 7
      days += /(\d+)(?=D)/.match(string).try &.[1].to_i || 0
      hours = /(\d+)(?=H)/.match(string).try &.[1].to_i || 0
      minutes = /(\d+)(?=M)/.match(string).try &.[1].to_i || 0
      seconds = /(\d+)(?=S)/.match(string).try &.[1].to_i || 0

      Time::Span.new(days, hours, minutes, seconds) * polarity
    end
  end
end
