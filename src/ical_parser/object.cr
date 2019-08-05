class Object
  macro getter(*names, type, value)
    {% for name in names %}
      @{{name.id}} : {{type.id}}?

      def {{name.id}}
        @{{name.id}} || {{value.id}}
      end
    {% end %}
  end
end
