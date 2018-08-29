require "minitest/autorun"

require "/../src/iCal"

class RecurrenceRuleTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
  end

  def test_initializes_ten_daily_occurrences
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Daily, count: 10)
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.count
  end

  def test_initializes_daily_until
    xmas_eve = Time.new(1997, 12, 24)
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Weekly, end_time: xmas_eve)
    assert_equal xmas_eve, recur.end_time
    assert_equal 1, recur.interval
    refute recur.count
  end

  def test_initializes_every_other_day_forever
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Daily, interval: 2)
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 2, recur.interval
  end

  def test_initializes_with_count_and_interval
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Daily, interval: 10, count: 5)
    assert_equal RecurrenceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.interval
    assert_equal 5, recur.count
    refute recur.end_time
  end

  def test_initializes_weekly_for_ten
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Weekly, count: 10)
    assert_equal RecurrenceRule::Freq::Weekly, recur.frequency
  end

  def test_first_friday_for_ten_months
    by_day = [{1, Time::DayOfWeek::Friday}]
    by_rules = { "by_day" => by_day } of String => RecurrenceRule::ByRuleType
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Monthly, count: 10, by_rules: by_rules)
    assert_equal by_day, recur.by_day
  end

  def test_weekly_tuesday_and_thursday
    by_day = [{0, Time::DayOfWeek::Tuesday}, {0, Time::DayOfWeek::Thursday}]
    by_rules = { "by_day" => by_day } of String => RecurrenceRule::ByRuleType
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Weekly, count: 10, by_rules: by_rules, week_start: Time::DayOfWeek::Sunday)
    assert_equal by_day, recur.by_day
    assert_equal Time::DayOfWeek::Sunday, recur.week_start
  end

  def test_every_day_in_january_for_three_years
    by_rules = { "by_month" => [1] } of String => RecurrenceRule::ByRuleType
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Monthly, end_time: Time.new(2000, 1, 31, 14, 0, 0), by_rules: by_rules)
    assert_equal [1], recur.by_month
  end

  def test_every_twenty_minutes_in_work_day
    by_hour = [9,10,11,12,13,14,15,16]
    by_minute = [0, 20, 40]
    by_rules = { "by_hour" => by_hour, "by_minute" => by_minute }
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Daily, by_rules: by_rules)
    assert_equal by_hour, recur.by_hour
    assert_equal by_minute, recur.by_minute
  end

  def test_monday_of_week_twenty
    by_week = [20]
    by_day = [{ 0, Time::DayOfWeek::Monday }]
    by_rules = { "by_week" => by_week, "by_day" => by_day }
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Yearly, by_rules: by_rules)
    assert_equal by_week, recur.by_week
    assert_equal by_day, recur.by_day
  end

  def test_yearday
    by_year_day = [1, 100, 200]
    by_rules = { "by_year_day" => by_year_day }
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Yearly, interval: 3, by_rules: by_rules)
    assert_equal 3, recur.interval
    assert_equal by_year_day, recur.by_year_day
  end

  def test_monthly_on_second_and_fifteenth
    by_month_day = [2, 15]
    by_rules = { "by_month_day" => by_month_day }
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Monthly, count: 10, by_rules: by_rules)
    assert_equal by_month_day, recur.by_month_day
    assert_equal 10, recur.count
  end

  def test_second_last_weekday
    by_day = [{ 0, Time::DayOfWeek::Monday }, { 0, Time::DayOfWeek::Tuesday }, { 0, Time::DayOfWeek::Wednesday }, { 0, Time::DayOfWeek::Thursday }, { 0, Time::DayOfWeek::Friday }]
    by_set_pos = [-2]
    by_rules = { "by_day" => by_day, "by_set_pos" => by_set_pos }
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Monthly, by_rules: by_rules)
    assert_equal by_day, recur.by_day
    assert_equal by_set_pos, recur.by_set_pos
  end

  def test_raises_assigning_count_to_rule_with_until
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Daily, count: 10)
    error = assert_raises do
      recur.end_time = Time.new(1997, 12, 24)
    end
    assert_equal "Invalid Assignment: Recurrence Rule cannot have both a count and an end time", error.message
  end

  def test_raises_assigning_until_to_rule_with_count
    recur = RecurrenceRule.new(RecurrenceRule::Freq::Weekly, end_time: Time.new(1997, 12, 24))
    error = assert_raises do
      recur.count = 10
    end
    assert_equal "Invalid Assignment: Recurrence Rule cannot have both a count and an end time", error.message
  end
end
