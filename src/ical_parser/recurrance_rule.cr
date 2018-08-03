module IcalParser
  # Representation of the Recurrance Rule.
  #
  # This class defines the repetition pattern of an event, to-do, jounral entry or time zone definition.
  #
  # # Specifies a recurrance rule for an event that will repeat every 2 days, up to 10 times.
  # recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10, 2)
  # recur.frequency #=> Daily
  # recur.count     #=> 10
  # recur.interval  #=> 2
  #
  # # Defines an Event that will repeat every year, indefinitely.
  # recur = RecurranceRule.new(RecurranceRule::Freq::Yearly)
  # props = {
  #   "uid"     => "canada-day@example.com",
  #   "dtstamp" => Time.utc(1867, 3, 29, 13, 0, 0),
  #   "dtstart" => Time.utc(1867, 7, 1),
  #   "recur"   => recur
  # } of String => PropertyType
  # event = IcalParser::Event.new(props)
  # event.recur.frequency #=> Yearly
  class RecurranceRule
    enum Freq
      Secondly
      Minutely
      Hourly
      Daily
      Weekly
      Monthly
      Yearly
    end

    property frequency : Freq
    property count : Int32?
    property interval = 1

    def initialize(@frequency : Freq, @count = nil, @interval = 1)
    end
  end
end
