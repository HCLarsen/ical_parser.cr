require "minitest/autorun"

require "/../src/iCal"

class PropertyTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @eventc = <<-HEREDOC
    BEGIN:VEVENT
    DTSTAMP:19960704T120000Z
    UID:uid1@example.com
    ORGANIZER:mailto:jsmith@example.com
    DTSTART:19960918T143000Z
    DTEND:19960920T220000Z
    STATUS:CONFIRMED
    CATEGORIES:CONFERENCE
    SUMMARY:Networld+Interop Conference
    DESCRIPTION:Networld+Interop Conference and Exhibit\nAtlanta World Congress Center\nAtlanta\, Georgia
    END:VEVENT
    HEREDOC
  end

  def test_returns_parser
    parser = EventParser.parser
    assert_equal EventParser, parser.class
  end

  def test_parser_is_singleton
    parser1 = EventParser.parser
    parser2 = EventParser.parser
    assert parser1.same?(parser2)
    error = assert_raises do
      parser1.dup
    end
    assert_equal "Can't duplicate instance of singleton IcalParser::EventParser", error.message
  end
end
