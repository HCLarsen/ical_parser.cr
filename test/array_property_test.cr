require "minitest/autorun"

require "/../src/iCal"

class ArrayPropertyTest < Minitest::Test
  class SetterClass
    array_setter numbers : String

    def numbers
      @numbers
    end
  end

  class PropertyClass
    array_property numbers : String
  end

  def initialize(arg)
    super(arg)
    @setter_tester = SetterClass.new
    @property_tester = PropertyClass.new
  end

  def test_setter_creates_nil_array
    assert_equal nil, @setter_tester.numbers
  end

  def test_setter_creates_standard_setter_method
    array = ["First", "Second"]
    @setter_tester.numbers = array
    assert_equal array, @setter_tester.numbers
  end

  def test_setter_creates_add_setter_method
    @setter_tester.add_numbers("Third")
    assert @setter_tester.numbers.not_nil!.includes?("Third")
  end

  def test_property_creates_getter_of_empty_array
    assert_equal [] of String, @property_tester.numbers
  end

  def test_property_creates_standard_setter_method
    array = ["First", "Second"]
    @property_tester.numbers = array
    assert_equal array, @property_tester.numbers
  end

  def test_property_creates_add_setter_method
    @property_tester.add_numbers("Third")
    assert @property_tester.numbers.includes?("Third")
  end
end
