require "minitest/autorun"

require "/../src/iCal"

class RecurrenceRuleParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, RecurrenceRuleType))

  def initialize(arg)
    super(arg)
    @parser = @@recurrence_parser
  end

  def test_daily_with_count
    string = "FREQ=DAILY;COUNT=10"
    recur = @parser.call(string)
    assert_equal "daily", recur["freq"]
    assert_equal 10, recur["count"]
  end

  def test_daily_with_until
    string = "FREQ=DAILY;UNTIL=19971224T000000Z"
    recur = @parser.call(string)
    assert_equal "19971224T000000Z", recur["until"]
  end

  def test_daily_with_interval
    string = "FREQ=DAILY;INTERVAL=2"
    recur = @parser.call(string)
    assert_equal "daily", recur["freq"]
    assert_equal 2, recur["interval"]
  end

  def test_yearly_by_month_by_day
    string = "FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA"
    recur = @parser.call(string)
    assert_equal [1], recur["bymonth"]
    assert_equal ["SU","MO","TU","WE","TH","FR","SA"], recur["byday"]
  end

  def test_by_positive_and_negative_days
    string = "FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU"
    recur = @parser.call(string)
    assert_equal ["1SU", "-1SU"], recur["byday"]
  end

  def test_multiple_by_xxx_rules
    string = "FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30"
    recur = @parser.call(string)
    assert_equal 2, recur["interval"]
    assert_equal [1], recur["bymonth"]
    assert_equal ["SU"], recur["byday"]
    assert_equal [8, 9], recur["byhour"]
    assert_equal [30], recur["byminute"]
  end

  def test_yearly_by_weekno
    string = "FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO"
    recur = @parser.call(string)
    assert_equal [20], recur["byweekno"]
  end

  def test_by_month_day
    string = "FREQ=MONTHLY;BYMONTHDAY=-3"
    recur = @parser.call(string)
    assert_equal [-3], recur["bymonthday"]
  end

  def test_by_year_day
    string = "FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200"
    recur = @parser.call(string)
    assert_equal [1, 100, 200], recur["byyearday"]
  end

  def test_set_pos
    string = "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2"
    recur = @parser.call(string)
    assert_equal [-2], recur["bysetpos"]
  end
end
