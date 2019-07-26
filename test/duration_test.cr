require "minitest/autorun"

require "/../src/ical_parser/duration"

class DurationTest < Minitest::Test
  include IcalParser

  def test_initializes_week
    duration = Duration.new(7)
    assert_equal 7, duration.weeks
  end

  def test_initializes_standard_form
    duration = Duration.new(days: 15, hours: 5, seconds: 20)
    assert_equal 15, duration.days
    assert_equal 5, duration.hours
    assert_equal 0, duration.minutes
    assert_equal 20, duration.seconds
  end

  def test_calculates_duration_between_dates
    date1 = Time.new(2019, 7, 25, 10, 8, 0)
    date2 = Time.new(2019, 7, 25, 11, 0, 0)
    expected = Duration.new(minutes: 52)
    assert_equal expected, Duration.between(date1, date2)
  end

  def test_parses_json_weeks
    json = %({"weeks":7})
    duration = Duration.from_json(json)
    assert_equal 7, duration.weeks
    assert_equal json, duration.to_json
  end

  def test_parses_standard_json
    json = %({"days":15,"hours":5,"seconds":20})
    duration = Duration.from_json(json)
    assert_equal 15, duration.days
    assert_equal 5, duration.hours
    assert_equal 0, duration.minutes
    assert_equal 20, duration.seconds
    assert_equal json, duration.to_json
  end

  def test_raises_for_json_with_weeks_and_days
    json = %({"weeks":7,"days":1})
    error = assert_raises do
      duration = Duration.from_json(json)
    end
    assert_equal "Error: Week durations cannot be combined with other duration units", error.message
  end
end
