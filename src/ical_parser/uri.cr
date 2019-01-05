module URIConverter
  def self.from_json(value : JSON::PullParser) : URI
    URI.parse(value.read_string)
  end
end
