require "minitest/autorun"

require "/../src/ical_parser/property_parsers/uri_parser"
require "/../src/ical_parser/common"
# require "/../src/iCal"

class URIParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@uri_parser
  end

  def test_parses_url_uris
    example = "http://example.com/pub/calendars/jsmith/mytime.ics"
    uri = @parser.call(example)
    assert_equal example, uri
  end

  def test_parses_mailto_uri
    example = "mailto:John.Doe@example.com"
    uri = @parser.call(example)
    assert_equal example, uri
  end
end
