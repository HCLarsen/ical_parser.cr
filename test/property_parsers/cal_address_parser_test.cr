require "minitest/autorun"

require "/../src/ical_parser/property_parsers/cal_address_parser"
require "/../src/ical_parser/common"
require "/../src/ical_parser/enums"

class CalAddressParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@caladdress_parser
  end

  def test_parses_simple_address
    string = "mailto:jsmith@example.com"
    params = Hash(String, String).new
    address = @parser.call(string, params)
    assert_equal %({"uri":"mailto:jsmith@example.com"}), address
  end

  def test_parses_rsvp
    string = "mailto:jsmith@example.com"
    params = {"RSVP" => "TRUE"}
    address = @parser.call(string, params)
    assert_equal %({"uri":"mailto:jsmith@example.com","rsvp":true}), address
  end

  def test_parses_cutype
    string = "mailto:ietf-calsch@example.org"
    params = {"CUTYPE" => "GROUP"}
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:ietf-calsch@example.org","cutype":"GROUP"})
    assert_equal expected, address
  end

  def test_parses_dir
    string = "mailto:jimdo@example.com"
    params = {"DIR" => %("ldap://example.com:6666/o=ABC%20Industries,c=US???(cn=Jim%20Dolittle)")}
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:jimdo@example.com","dir":"ldap://example.com:6666/o=ABC%20Industries,c=US???(cn=Jim%20Dolittle)"})
    assert_equal expected, address
  end

  def test_parses_sent_by
    params = {"SENT-BY" => "mailto:sray@example.com"}
    string = "mailto:jsmith@example.com"
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:jsmith@example.com","sent-by":{"uri":"mailto:sray@example.com"}})
    assert_equal expected, address
  end

  def test_parses_members
    string = "mailto:jsmith@example.com"
    params = {"MEMBER" => %("mailto:projectA@example.com","mailto:projectB@example.com")}
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:jsmith@example.com","member":[{"uri":"mailto:projectA@example.com"},{"uri":"mailto:projectB@example.com"}]})
    assert_equal expected, address
  end

  def test_parses_delegated_from
    string = "mailto:ildoit@example.com"
    params = {"DELEGATED-FROM" => %("mailto:immud@example.com")}
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:ildoit@example.com","delegated-from":[{"uri":"mailto:immud@example.com"}]})
    assert_equal expected, address
  end

  def test_parses_multiple_delegated_to
    params = {"DELEGATED-TO" => %("mailto:jdoe@example.com","mailto:jqpublic@example.com")}
    string = "jsmith@example.com"
    address = @parser.call(string, params)
    expected = %({"uri":"jsmith@example.com","delegated-to":[{"uri":"mailto:jdoe@example.com"},"uri":"mailto:jqpublic@example.com"]})
  end

  def test_parses_complicated_cal_address
    params = {"ROLE" => "NON-PARTICIPANT", "PARTSTAT" => "DELEGATED", "DELEGATED-TO" => "mailto:hcabot@example.com", "CN" => "The Big Cheese"}
    string = "mailto:iamboss@example.com"
    address = @parser.call(string, params)
    expected = %({"uri":"mailto:iamboss@example.com","role":"NON-PARTICIPANT","partstat":"DELEGATED","delegated-to":[{"uri":"mailto:hcabot@example.com"}],"cn":"The Big Cheese"})
    assert_equal expected, address
  end
end
