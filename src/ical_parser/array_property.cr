class Object
  # Declares a nilable array of the type provided, as well as
  # a setter and an add method tailored to the variable name
  # for each of the arguments provided.
  #
  # Writing:
  #
  # ```
  # class Person
  #   array_setter names : String
  # end
  # ```
  #
  # is the same as writing:
  #
  # ```
  # class Person
  #   @names : Array(String)?
  #
  #   def names=(@name : String)
  #   end
  #
  #   def add_names(*elements : String)
  #     if (value = @names).nil?
  #       value = elements.to_a
  #     else
  #  		  elements.each do |element|
  #			    value.push(element)
  #		    end
  #     end
  #     @names = value
  #	  end
  # end
  # ```
  #
  # Unlike standard setters, a type MUST BE provided, and
  # default values are not accepted.
  macro array_setter(*names)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        @{{name.var.id}} : Array({{name.type}})?

        def {{name.var.id}}=(@{{name.var.id}} : Array({{name.type}})?)
        end

        def add_{{name.var.id}}(element : {{name.type}})
          if (value = @{{name.var.id}}).nil?
            value = [element]
          else
            value << element
          end
          @{{name.var.id}} = value
        end
      {% end %}
    {% end %}
  end

  # Declares a nilable array of the type provided, as well as
  # a getter, a setter and an add method tailored to the
  # variable name for each of the arguments provided.
  #
  # Writing:
  #
  # ```
  # class Person
  #   array_property names : String
  # end
  # ```
  #
  # is the same as writing:
  #
  # ```
  # class Person
  #   @names : Array(String)?
  #
  #   def names : Array(String)
  #     if (value = @names).nil?
  #       [] of String
  #     else
  #       @names.not_nil!
  #     end
  #   end
  #
  #   def names=(@name : String)
  #   end
  #
  #   def add_names(*elements : String)
  #     if (value = @names).nil?
  #       value = elements.to_a
  #     else
  #  		  elements.each do |element|
  #			    value.push(element)
  #		    end
  #     end
  #     @names = value
  #	  end
  # end
  # ```
  #
  # Unlike a standard property, a type MUST BE provided,
  # and default values are not accepted.
  macro array_property(*names)
    {% for name in names %}
      {% if name.is_a?(TypeDeclaration) %}
        @{{name.var.id}} : Array({{name.type}})?

        def {{name.var.id}}=(@{{name.var.id}} : Array({{name.type}})?)
        end

        def add_{{name.var.id}}(element : {{name.type}})
          if (value = @{{name.var.id}}).nil?
            value = [element]
          else
            value << element
          end
          @{{name.var.id}} = value
        end

        def {{name.var.id}} : Array({{name.type}})
          if (value = @{{name.var.id}}).nil?
            [] of {{name.type}}
          else
            @{{name.var.id}}.not_nil!
          end
        end
      {% end %}
    {% end %}
  end
end
