# frozen_string_literal: true

module Rover
  class Vector
    BOOLEAN_VALUES = [true, false].freeze
    # rubocop:disable
    def cast_data(data, type: :object) # Assign :object if no type specified. Casting is the source of most issues.
      numo_type = numo_type(type) if type

      data = data.to_numo if data.is_a?(Vector)

      if data.is_a?(Numo::NArray)
        raise ArgumentError, "Complex types not supported yet" if data.is_a?(Numo::DComplex) || data.is_a?(Numo::SComplex)

        if type
          case type
          when /int/
            # Numo does not check these when casting
            raise RangeError, "float NaN out of range of integer" if data.respond_to?(:isnan) && data.isnan.any?
            raise RangeError, "float Inf out of range of integer" if data.respond_to?(:isinf) && data.isinf.any?

            data = data.to_a.map { |v| v.nil? ? nil : v.to_i } if data.is_a?(Numo::RObject)
          when /float/
            data = data.to_a.map { |v| v.nil? ? Float::NAN : v.to_f } if data.is_a?(Numo::RObject)
          end

          data = numo_type.cast(data)
        end
      else
        data = data.to_a
        data = if type
          numo_type.cast(data)
        elsif data.present? && data.all? { |v| v.is_a?(NilClass) }
          Numo::RObject.cast(data)
        elsif data.present? && data.all? { |v| v.is_a?(Integer) }
          Numo::Int64.cast(data)
        elsif data.present? && data.all? { |v| v.is_a?(Numeric) }
          Numo::DFloat.cast(data.map { |v| v || Float::NAN })
        elsif data.present? && data.all? { |v| [true, false].include?(v) }
          Numo::Bit.cast(data)
        else
          Numo::RObject.cast(data)
        end
      end

      data
    end

    def [](vect)
      return Vector.new(vect.to_numo.mask(@data)) if vect.is_a?(Vector)

      value = @data[vect]
      case type
      when :bool
        value.positive?
      else
        value
      end
    end

    %w[+ - * / % ** & | ^].each do |op|
      define_method(op) do |other|
        other = other.to_numo if other.is_a?(Vector)
        # Cast booleans to ints to allow for comparison
        other = Numo::Bit.cast(((other && 1) || 0)) if BOOLEAN_VALUES.include?(other)

        if @data.is_a?(Numo::RObject) && !other.is_a?(Numo::RObject)
          map { |v| v.send(op, other) }
        else
          Vector.new(@data.send(op, other))
        end
      end
    end

    {
      "==" => "eq",
      "!=" => "ne",
      ">" => "gt",
      ">=" => "ge",
      "<" => "lt",
      "<=" => "le"
    }.each do |op, meth|
      define_method(op) do |other|
        other = other.to_numo if other.is_a?(Vector)
        v =
          if other.is_a?(Numo::RObject)
            @data.to_a.zip(other).map { |v, ov| v == ov }
          elsif other.is_a?(Numeric) || other.is_a?(Numo::NArray)
            @data.send(meth, other)
          else
            @data.to_a.map { |v| v.send(op, other) }
          end
          Vector.new(Numo::Bit.cast(v))
      end
    end
    # rubocop:enable
  end
end
