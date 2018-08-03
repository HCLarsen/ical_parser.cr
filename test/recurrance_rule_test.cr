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

  def test_initializes_simple_recurrance_rule
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10, 2)
    assert_equal RecurranceRule::Freq::Daily, recur.frequency
    assert_equal 10, recur.count
    assert_equal 2, recur.interval
  end
end
