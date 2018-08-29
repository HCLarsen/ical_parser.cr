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
end
