require "json"
require "./../object"
require "./../common"
require "./../enums"

module IcalParser
  abstract class Component
    PROPERTIES = {} of String => NamedTuple
    X_PROPERTIES = {} of String => NamedTuple
    COMPONENTS = {} of String => NamedTuple
    X_COMPONENTS = {} of String => NamedTuple

    macro mapping
      JSON.mapping(
        {% _properties_ = {} of String => NamedTuple %}
        {% _components_ = {} of String => NamedTuple %}

        {% for key, value in PROPERTIES %}
          {% _properties_[key] = value %}
        {% end %}
        {% for key, value in X_PROPERTIES %}
          {% _properties_[key] = value %}
        {% end %}

        {% for key, value in COMPONENTS %}
          {% _components_[key] = value %}
        {% end %}
        {% for key, value in X_COMPONENTS %}
          {% _components_[key] = value %}
        {% end %}

        {% for key, value in _properties_ %}
          {% _property = COMPONENT_PROPERTIES[value[:name]] %}
          {% value[:type] = CLASSES[_property[:types][0]] %}
          {% value[:key] = value[:key] || value[:name] %}
          {% value[:nilable] = !value[:required] %}
          {% value[:converter] = _property[:converter] %}
          {% if value[:only_once] == false || _property[:list] == true %}
            {{value[:key].id}}: { type: Array({{value[:type].id}}){{ (value[:required] ? "" : "?").id }}, converter: {{value[:converter]}} },
          {% elsif _property[:parts] %}
            {{value[:key].id}}: { type: Hash(String, {{value[:type].id}}){{ (value[:required] ? "" : "?").id }} , converter: {{value[:converter]}} },
          {% else %}
            {{value[:key].id}}: {{value.id}},
          {% end %}
        {% end %}

        {% for key, value in _components_ %}
          {% value[:key] = value[:key] || value[:name] %}
          {{value[:key].id}}: { type: Array({{value[:class].id}}){{ "?".id }} },
        {% end %}
      )
    end
  end
end
