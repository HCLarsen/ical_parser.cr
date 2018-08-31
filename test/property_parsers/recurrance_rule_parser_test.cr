require "minitest/autorun"

require "/../src/iCal"

class RecurrenceRuleParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = RecurrenceRuleParser.parser
  end

  def test_daily_with_count
    string = "FREQ=DAILY;COUNT=10"
    recur = @parser.parse(string)
    assert_equal 10, recur.count
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 1, recur.interval
  end

  def test_daily_with_until
    string = "FREQ=DAILY;UNTIL=19971224T000000Z"
    recur = @parser.parse(string)
    assert_equal Time.utc(1997, 12, 24), recur.end_time
    assert_equal 1, recur.interval
  end

  def test_daily_with_interval
    string = "FREQ=DAILY;INTERVAL=2"
    recur = @parser.parse(string)
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 2, recur.interval
  end

  def test_yearly_by_month_by_day
    string = "FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA"
    sundays = {0, Time::DayOfWeek::Sunday}
    recur = @parser.parse(string)
    assert_equal [1], recur.by_month
    assert_equal sundays, recur.by_day.not_nil!.first
  end

  def test_by_positive_and_negative_days
    string = "FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU"
    first_sunday = {1, Time::DayOfWeek::Sunday}
    last_sunday = {-1, Time::DayOfWeek::Sunday}
    recur = @parser.parse(string)
    assert_equal first_sunday, recur.by_day.not_nil!.first
    assert_equal last_sunday, recur.by_day.not_nil!.last
  end
end
