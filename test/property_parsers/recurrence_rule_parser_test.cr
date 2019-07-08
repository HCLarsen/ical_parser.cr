require "minitest/autorun"

require "/../src/ical_parser/property_parsers/recurrence_rule_parser"
require "/../src/ical_parser/common"
require "/../src/ical_parser/enums"

class RecurrenceRuleParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@recurrence_parser
    @params = Hash(String, String).new
  end

  def test_daily_with_count
    string = "FREQ=DAILY;COUNT=10"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"daily","count":10}), recur
  end

  def test_daily_with_until
    string = "FREQ=DAILY;UNTIL=19971224T000000Z"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"daily","until":"19971224T000000Z"}), recur
  end

  def test_daily_with_interval
    string = "FREQ=DAILY;INTERVAL=2"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"daily","interval":2}), recur
  end

  def test_yearly_by_month_by_day
    string = "FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"yearly","until":"20000131T140000Z","bymonth":[1],"byday":["SU","MO","TU","WE","TH","FR","SA"]}), recur
  end

  def test_by_positive_and_negative_days
    string = "FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"monthly","interval":2,"count":10,"byday":["1SU","-1SU"]}), recur
  end

  def test_multiple_by_xxx_rules
    string = "FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"yearly","interval":2,"bymonth":[1],"byday":["SU"],"byhour":[8,9],"byminute":[30]}), recur
  end

  def test_yearly_by_weekno
    string = "FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"yearly","byweekno":[20],"byday":["MO"]}), recur
  end

  def test_by_month_day
    string = "FREQ=MONTHLY;BYMONTHDAY=-3"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"monthly","bymonthday":[-3]}), recur
  end

  def test_by_year_day
    string = "FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"yearly","interval":3,"count":10,"byyearday":[1,100,200]}), recur
  end

  def test_set_pos
    string = "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2"
    recur = @parser.call(string, @params)
    assert_equal %({"freq":"monthly","byday":["MO","TU","WE","TH","FR"],"bysetpos":[-2]}), recur
  end
end
