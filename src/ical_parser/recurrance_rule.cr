module IcalParser
  # Representation of the Recurrance Rule.
  #
  # This class defines the repetition pattern of an event, to-do, jounral entry or time zone definition.
  #
  # recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10, 2)
  # recur.frequency #=> Daily
  # recur.count     #=> 10
  # recur.interval  #=> 2
  #
  # # Defines an Event that will repeat every 2 days, up to 10 times.
  # props = {
  #   "uid"     => "19970901T130000Z-123401@example.com",
  #   "dtstamp" => Time.utc(1997, 9, 1, 13, 0, 0),
  #   "dtstart" => Time.utc(1997, 9, 3, 16, 30, 0),
  #   "dtend"   => Time.utc(1997, 9, 3, 19, 0, 0),
  #   "recur"   => recur
  # } of String => PropertyType
  # event = IcalParser::Event.new(props)
  # event.recur.frequency #=> Daily
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
    property count : Int32
    property interval : Int32

    def initialize(@frequency : Freq, @count : Int32, @interval : Int32)
    end
  end
end
