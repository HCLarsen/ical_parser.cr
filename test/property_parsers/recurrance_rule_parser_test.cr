require "minitest/autorun"

require "/../src/iCal"

class RecurranceRuleParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = RecurranceRuleParser.parser
  end
end
