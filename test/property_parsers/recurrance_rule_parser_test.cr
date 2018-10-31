require "minitest/autorun"

require "/../src/iCal"

class RecurrenceRuleParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), RecurrenceRule)

  def initialize(arg)
    super(arg)
    @parser = @@recurrence_parser
    @params = Hash(String, String).new
  end

  def test_daily_with_count
    string = "FREQ=DAILY;COUNT=10"
    recur = @parser.call(string, @params)
    assert_equal 10, recur.count
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 1, recur.interval
  end

  def test_daily_with_until
    string = "FREQ=DAILY;UNTIL=19971224T000000Z"
    recur = @parser.call(string, @params)
    assert_equal Time.utc(1997, 12, 24), recur.end_time
    assert_equal 1, recur.interval
  end

  def test_daily_with_interval
    string = "FREQ=DAILY;INTERVAL=2"
    recur = @parser.call(string, @params)
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 2, recur.interval
  end

  def test_yearly_by_month_by_day
    string = "FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA"
    sundays = {0, Time::DayOfWeek::Sunday}
    recur = @parser.call(string, @params)
    assert_equal [1], recur.by_month
    assert_equal sundays, recur.by_day.not_nil!.first
  end

  def test_by_positive_and_negative_days
    string = "FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU"
    first_sunday = {1, Time::DayOfWeek::Sunday}
    last_sunday = {-1, Time::DayOfWeek::Sunday}
    recur = @parser.call(string, @params)
    assert_equal [first_sunday, last_sunday], recur.by_day
  end

  def test_multiple_by_xxx_rules
    string = "FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30"
    recur = @parser.call(string, @params)
    assert_equal RecurrenceRule::Freq::Yearly, recur.frequency
    assert_equal 2, recur.interval
    assert_equal [1], recur.by_month
    assert_equal [{0, Time::DayOfWeek::Sunday}], recur.by_day
    assert_equal [8, 9], recur.by_hour
    assert_equal [30], recur.by_minute
  end

  def test_yearly_by_weekno
    string = "FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO"
    recur = @parser.call(string, @params)
    assert_equal [20], recur.by_week
  end

  def test_by_month_day
    string = "FREQ=MONTHLY;BYMONTHDAY=-3"
    recur = @parser.call(string, @params)
    assert_equal [-3], recur.by_month_day
  end

  def test_by_year_day
    string = "FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200"
    recur = @parser.call(string, @params)
    assert_equal [1, 100, 200], recur.by_year_day
  end

  def test_set_pos
    string = "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2"
    recur = @parser.call(string, @params)
    assert_equal [-2], recur.by_set_pos
  end
end
