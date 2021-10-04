# frozen_string_literal: true

require "active_support/concern"

module Notifications
  module FilterMethodDefiner
    extend ActiveSupport::Concern

    def define_setters(*attributes)
      attributes.each do |attribute|
        # Define the dynamic setters
        define_setter(attribute: attribute)
      end
    end

    def define_getters(*attributes)
      attributes.each do |attribute|
        # Define the dynamic setters
        define_getter(attribute: attribute)
      end
    end

    def define_setter(attribute:)
      define_method("#{attribute}=") do |input|
        filter[attribute] = input
      end
    end

    def define_getter(attribute:)
      define_method(attribute.to_s) do
        filter[attribute]
      end
    end
  end
end
