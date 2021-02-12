# frozen_string_literal: true

require "active_support/concern"

module ContentSetter
  extend ActiveSupport::Concern

  def define_setters(*attrs)
    attrs.each do |attr|
      # Define the dynamic setters
      define_method("#{attr}=") do |val|
        default_value = Organizations::DEFAULT_SCOPE.fetch(attr)
        if [true, false].include?(default_value)
          content[attr] = ActiveRecord::Type::Boolean.new.cast(val)
        elsif default_value.is_a?(Integer)
          content[attr] = val.to_i
        else
          content[attr] = val
        end
      end
    end
  end
end
