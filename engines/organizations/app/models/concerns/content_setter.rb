# frozen_string_literal: true

require "active_support/concern"

# Enables us to use AR model setters to manipulate scope values in the content hash
module ContentSetter
  extend ActiveSupport::Concern

  def define_setters(*attributes)
    attributes.each do |attribute|
      # Define the dynamic setters
      define_setter(attribute: attribute)
    end
  end

  def define_setter(attribute:)
    define_method("#{attribute}=") do |input|
      content[attribute] = ScopeValue.new(attribute: attribute, input: input).perform
    end
  end

  # Class to ensure the correct value is stored in the hash
  class ScopeValue
    def initialize(attribute:, input:)
      @attribute = attribute
      @input = input
    end

    def perform
      if [true, false].include?(default_value)
        ActiveRecord::Type::Boolean.new.cast(input)
      elsif default_value.is_a?(Integer)
        input.to_i
      elsif default_value.is_a?(NilClass)
        input.presence || nil
      else
        input
      end
    end

    private

    attr_reader :attribute, :input

    def default_value
      Organizations::DEFAULT_SCOPE.fetch(attribute)
    end
  end
end
