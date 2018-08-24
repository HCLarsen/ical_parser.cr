require "minitest/autorun"

require "/../src/iCal"

class RecurranceRuleTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
  end

  def test_initializes_ten_daily_occurrences
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10)
    assert_equal RecurranceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.count
  end

  def test_initializes_daily_until
    xmas_eve = Time.new(1997, 12, 24)
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, xmas_eve)
    assert_equal xmas_eve, recur.end_time
    assert_equal 1, recur.interval
    refute recur.count
  end

  def test_initializes_every_other_day_forever
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, interval: 2)
    assert_equal RecurranceRule::Freq::Daily, recur.frequency
    assert_equal 2, recur.interval
  end

  def test_initializes_with_count_and_interval
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, interval: 10, count: 5)
    assert_equal RecurranceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.interval
    assert_equal 5, recur.count
    refute recur.end_time
  end

  def test_initializes_weekly_for_ten
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, count: 10)
    assert_equal RecurranceRule::Freq::Weekly, recur.frequency
  end

  def test_initializes_recurrance_with_by_day
    by_day = [{1, Time::DayOfWeek::Friday}]
    by_rules = { "by_day" => by_day }
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, count: 10, by_rules: by_rules, week_start: Time::DayOfWeek::Sunday)
    assert_equal by_day, recur.by_day
  end
end
