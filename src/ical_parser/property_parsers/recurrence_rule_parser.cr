module IcalParser
  alias RecurrenceRuleType = String | Int32 | Array(String) | Array(Int32)
  # The recurrence_parser function parses the RFC5545 [Recurrence Rule](https://tools.ietf.org/html/rfc5545#section-3.3.10) value type and returns a JSON object.
  #
  # recur = @@recurrence_parser.call("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
  # recur #=> {"freq":"weekly","until":"","wkst":"SU","by_day":["tu","th"]}
  @@recurrence_parser = Proc(String, Hash(String, String), Hash(String, RecurrenceRuleType)).new do |value, params|

    hash = {} of String => RecurrenceRuleType
    pairs = value.split(';')
    pairs.each do  |pair|
      name, value = pair.split('=')
      name = name.downcase
      if name == "byday"
        hash[name] = value.split(',')
      elsif name.starts_with?("by")
        hash[name] = value.split(',').map(&.to_i)
      elsif name == "interval" || name == "count"
        hash[name] = value.to_i
      elsif name == "freq"
        hash[name] = value.downcase
      else
        hash[name] = value
      end
    end

    hash

    # frequency = RecurrenceRule::Freq.from_string(hash["freq"].downcase)
    # interval = hash["interval"]? ? hash["interval"].to_i : 1
    #
    # rules = {} of String => RecurrenceRule::ByRuleType
    #
    # rules["by_month"] = hash["bymonth"].split(',').map(&.to_i) if hash["bymonth"]?
    # rules["by_week"] = hash["byweekno"].split(',').map(&.to_i) if hash["byweekno"]?
    # rules["by_month_day"] = hash["bymonthday"].split(',').map(&.to_i) if hash["bymonthday"]?
    # rules["by_year_day"] = hash["byyearday"].split(',').map(&.to_i) if hash["byyearday"]?
    # rules["by_hour"] = hash["byhour"].split(',').map(&.to_i) if hash["byhour"]?
    # rules["by_minute"] = hash["byminute"].split(',').map(&.to_i) if hash["byminute"]?
    # rules["by_second"] = hash["bysecond"].split(',').map(&.to_i) if hash["bysecond"]?
    # rules["by_set_pos"] = hash["bysetpos"].split(',').map(&.to_i) if hash["bysetpos"]?
    #
    # if hash["byday"]?
    #   byday_regex = /(?<num>-?[1-9]?)(?<day>[A-Z]{2})/
    #   days = hash["byday"].split(',')
    #   matches = days.map { |day| day.match(byday_regex) }
    #   rules["by_day"] = matches.compact.map do |match|
    #     num = match["num"].empty? ? 0 : match["num"].to_i
    #     {num, day_to_day_of_week(match["day"])}
    #   end
    # end
    #
    # if hash["until"]?
    #   until_string = hash["until"].upcase
    #   params = Hash(String, String).new
    #
    #   end_time = @@date_time_parser.call(until_string, params)
    #   RecurrenceRule.new(frequency, end_time: end_time, by_rules: rules, interval: interval)
    # elsif hash["count"]?
    #   count = hash["count"].to_i
    #   RecurrenceRule.new(frequency, count: count, by_rules: rules, interval: interval)
    # else
    #   RecurrenceRule.new(frequency, by_rules: rules, interval: interval)
    # end
  end

  private def self.day_to_day_of_week(day : String) : Time::DayOfWeek
    case day
    when "MO"
      Time::DayOfWeek::Monday
    when "TU"
      Time::DayOfWeek::Tuesday
    when "WE"
      Time::DayOfWeek::Wednesday
    when "TH"
      Time::DayOfWeek::Thursday
    when "FR"
      Time::DayOfWeek::Friday
    when "SA"
      Time::DayOfWeek::Saturday
    when "SU"
      Time::DayOfWeek::Sunday
    else
      raise "Invalid Day of Week value: #{day}"
    end
  end
end
