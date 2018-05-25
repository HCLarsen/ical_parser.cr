require "minitest/autorun"

require "/../src/iCal"

class URIParserTest < Minitest::Test
  def test_parses_url_uris
    examples = [
      "http://example.com/pub/calendars/jsmith/mytime.ics",
      "ftp://ftp.is.co.za/rfc/rfc1808.txt",
      "http://www.ietf.org/rfc/rfc2396.txt",
      "ldap://[2001:db8::7]/c=GB?objectClass?one",
      "telnet://192.0.2.16:80/",
    ]
    parsed_examples = [
      {"scheme" => "http", "host" => "example.com", "hier-part" => "example.com/pub/calendars/jsmith/mytime.ics"},
      {"scheme" => "ftp", "host" => "ftp.is.co.za", "hier-part" => "ftp.is.co.za/rfc/rfc1808.txt"},
      {"scheme" => "http", "host" => "www.ietf.org", "hier-part" => "www.ietf.org/rfc/rfc2396.txt"},
      {"scheme" => "ldap", "host" => "[2001:db8::7]", "hier-part" => "[2001:db8::7]/c=GB?objectClass?one"},
      {"scheme" => "telnet", "host" => "192.0.2.16", "hier-part" => "192.0.2.16:80/"},
    ]
    examples.each_with_index do |example, i|
      uri = ICal::URIParser.parse(example)
      assert_equal parsed_examples[i]["scheme"], uri.scheme
      assert_equal parsed_examples[i]["host"], uri.host
    end
  end

  def test_parses_mailto_uri
    example = "mailto:John.Doe@example.com"
    uri = ICal::URIParser.parse(example)
    assert_equal "mailto", uri.scheme
    assert_equal "John.Doe@example.com", uri.opaque
  end
end
