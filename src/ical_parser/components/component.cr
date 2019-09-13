module IcalParser
  abstract class Component
    PROPERTIES = {} of String => NamedTuple

    macro mapping
      JSON.mapping(
        {% for key, value in PROPERTIES %}
          {% _property = COMPONENT_PROPERTIES[value[:name]] %}
          {% _class = CLASSES[_property[:types][0]] %}
          {% value[:type] = _class %}
          {% value[:key] = value[:key] || value[:name] %}
          {% value[:nilable] = !value[:required] %}
          {% value[:converter] = _property[:converter] %}
          {% if value[:only_once] == false || _property[:list] == true %}
            {{value[:key].id}}: { type: Array({{_class.id}}){{ (value[:required] ? "" : "?").id }}, converter: {{value[:converter]}} },
          {% elsif _property[:parts] %}
            {{value[:key].id}}: { type: Hash(String, {{_class.id}}){{ (value[:required] ? "" : "?").id }} , converter: {{value[:converter]}} },
          {% else %}
            {{value[:key].id}}: {{value.id}},
          {% end %}
        {% end %}
        all_day: {type: Bool?, key: "all-day", getter: false}
      )
    end
  end
end
