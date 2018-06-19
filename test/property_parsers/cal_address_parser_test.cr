require "minitest/autorun"

require "/../src/iCal"
require "/../src/ical_parser/cal_address"

class CalAddressParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = CalAddressParser.parser
  end

  def test_parses_simple_address
    string = "mailto:jsmith@example.com"
    uri = URI.parse(string)
    address = @parser.parse(string)
    assert_equal uri, address.uri
  end

  def test_parses_rsvp
    string = "mailto:jsmith@example.com"
    params = { "RSVP" => "TRUE"}
    address = @parser.parse(string, params)
    assert address.rsvp
  end

  def test_parses_cutype
    string = "mailto:ietf-calsch@example.org"
    params = { "CUTYPE" => "GROUP"}
    address = @parser.parse(string, params)
    assert_equal CalAddress::CUType::Group, address.cutype
  end

  def test_parses_dir
    string = "mailto:jimdo@example.com"
    params = { "DIR" => %("ldap://example.com:6666/o=ABC%20Industries,c=US???(cn=Jim%20Dolittle)") }
    address = @parser.parse(string, params)
    assert_equal "example.com", address.dir.not_nil!.host
  end

  def test_parses_sent_by
    params = { "SENT-BY" => "mailto:sray@example.com" }
    string = "mailto:jsmith@example.com"
    address = @parser.parse(string, params)
    assert_equal "sray@example.com", address.sent_by.not_nil!.uri.opaque
  end

  def test_parses_members
    string = "mailto:jsmith@example.com"
    params = { "MEMBER" => %("mailto:projectA@example.com","mailto:projectB@example.com") }
    address = @parser.parse(string, params)
    assert_equal 2, address.member.size
    assert_equal "projectA@example.com", address.member.first.uri.opaque
  end

  def test_parses_delegated_from
    string = "mailto:ildoit@example.com"
    params = { "DELEGATED-FROM" => %("mailto:immud@example.com")}
    address = @parser.parse(string, params)
    assert_equal 1, address.delegated_from.size
    assert_equal "immud@example.com", address.delegated_from.first.uri.opaque
  end

  def test_parses_multiple_delegated_to
    params = { "DELEGATED-TO" => %("mailto:jdoe@example.com","mailto:jqpublic@example.com") }
    string = "jsmith@example.com"
    address = @parser.parse(string, params)
    assert_equal 2, address.delegated_to.size
    assert_equal "jdoe@example.com", address.delegated_to.first.uri.opaque
  end

  def test_parses_complicated_cal_address
    params = { "ROLE" => "NON-PARTICIPANT" , "PARTSTAT" => "DELEGATED", "DELEGATED-TO" => "mailto:hcabot@example.com", "CN" => "The Big Cheese" }
    string = "mailto:iamboss@example.com"
    address = @parser.parse(string, params)
    assert_equal "iamboss@example.com", address.uri.opaque
    assert_equal "The Big Cheese", address.common_name

    delegated = CalAddress.new(URI.parse("mailto:hcabot@example.com"))
    assert_equal 1, address.delegated_to.size
    assert_equal delegated.uri.opaque, address.delegated_to.first.uri.opaque

    assert_equal CalAddress::Role::NonParticipant, address.role
    assert_equal CalAddress::PartStat::Delegated, address.part_stat
  end
end
