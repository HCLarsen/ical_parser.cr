module URIConverter
  def self.from_json(value : JSON::PullParser) : URI
    URI.parse(value.read_string)
  end

  def self.to_json(value : URI, json : JSON::Builder)
    value.to_s.to_json(json)
  end
end
