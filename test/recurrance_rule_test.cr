require "minitest/autorun"

require "/../src/iCal"

class RecurranceRuleTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
  end

  def test_initializes_indefinitely_repeating_rule
    recur = RecurranceRule.new(RecurranceRule::Freq::Yearly)
    assert_equal RecurranceRule::Freq::Yearly, recur.frequency
  end

  def test_initializes_recurrance_with_count
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10, 2)
    assert_equal RecurranceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.count
    assert_equal 2, recur.interval
    refute recur.end_time
  end

  def test_initializes_recurrance_with_until
    xmas_eve = Time.new(1997, 12, 24)
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, xmas_eve)
    assert_equal xmas_eve, recur.end_time
    assert_equal 1, recur.interval
    refute recur.count
  end

  def test_initializes_recurrance_with_by_day
    by_day = [{0, Time::DayOfWeek::Tuesday}, {0, Time::DayOfWeek::Thursday}]
    by_rules = { "by_day" => by_day }
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, count: 10, by_rules: by_rules , week_start: Time::DayOfWeek::Sunday)
    assert_equal by_day, recur.by_day
  end
end
