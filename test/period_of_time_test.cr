require "minitest/autorun"

require "/../src/iCal"

class PeriodOfTimeTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
  end

  def test_initializes_with_start_and_end
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    end_time = Time.new(1997, 1, 2, 7, 0, 0)
    period = PeriodOfTime.new(start_time, end_time)
    assert_equal start_time, period.start_time
    assert_equal end_time, period.end_time
    assert_equal end_time - start_time, period.duration
  end

  def test_initializes_with_start_and_duration
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    duration = Time::Span.new(5, 30, 0)
    period = PeriodOfTime.new(start_time, duration)
    assert_equal start_time, period.start_time
    assert_equal start_time + duration, period.end_time
    assert_equal duration, period.duration
  end

  def test_raises_for_same_start_and_end
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    end_time = Time.new(1997, 1, 1, 18, 0, 0)
    error = assert_raises do
      period = PeriodOfTime.new(start_time, end_time)
    end
    assert_equal "Invalid PeriodOfTime: end_time must be later than start time", error.message
  end

  def test_raises_for_end_earlier_than_start
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    end_time = Time.new(1997, 1, 1, 16, 0, 0)
    error = assert_raises do
      period = PeriodOfTime.new(start_time, end_time)
    end
    assert_equal "Invalid PeriodOfTime: end_time must be later than start time", error.message
  end

  def test_raises_for_negative_duration_initialization
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    duration = Time::Span.new(-5, 30, 0)
    error = assert_raises do
      period = PeriodOfTime.new(start_time, duration)
    end
    assert_equal "Invalid PeriodOfTime: duration must be positive", error.message
  end

  def test_raises_for_invalid_end_assignment
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    end_time = Time.new(1997, 1, 2, 7, 0, 0)
    period = PeriodOfTime.new(start_time, end_time)
    error = assert_raises do
      period.end_time = Time.new(1997, 1, 1, 16, 0, 0)
    end
    assert_equal "Invalid end_time: must be later than start time", error.message
  end

  def test_raises_for_invalid_start_assignment
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    end_time = Time.new(1997, 1, 2, 7, 0, 0)
    period = PeriodOfTime.new(start_time, end_time)
    error = assert_raises do
      period.start_time = Time.new(1997, 1, 2, 8, 0, 0)
    end
    assert_equal "Invalid start_time: must be earlier than end time", error.message
  end

  def test_raises_for_negative_duration_assignment
    start_time = Time.new(1997, 1, 1, 18, 0, 0)
    duration = Time::Span.new(5, 30, 0)
    period = PeriodOfTime.new(start_time, duration)
    error = assert_raises do
      period.duration = Time::Span.new(-1, 30, 0)
    end
    assert_equal "Invalid duration: must be positive", error.message
  end

  def test_parses_and_outputs_json
    json = %({"start":852159600,"end":852206400})
    period = PeriodOfTime.from_json(json)
    assert_equal Time.new(1997, 1, 1, 18, 0, 0), period.start_time
    assert_equal Time.new(1997, 1, 2, 7, 0, 0), period.end_time
    assert_equal json, period.to_json
  end
end
