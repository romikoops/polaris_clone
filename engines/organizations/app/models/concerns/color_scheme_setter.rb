# frozen_string_literal: true

require "active_support/concern"

# Enables us to use AR model setters to manipulate scope values in the content hash
module ColorSchemeSetter
  extend ActiveSupport::Concern

  def define_setters(*attributes)
    attributes.each do |attribute|
      # Define the dynamic setters
      define_method("#{attribute}=") do |input|
        color_scheme[attribute] = input
      end
    end
  end
end
