# frozen_string_literal: true

require "active_support/concern"

module Wheelhouse::ErrorHandler
  extend ActiveSupport::Concern

  included do
    def handle_error(error:)
      parent = self.class.parent
      error_class = error.class.name.sub("OfferCalculator::Errors::", "")
      base_error = parent.const_defined?("ApplicationError") ? parent.const_get(:ApplicationError) : ApplicationError

      raise base_error.const_get(error_class)
    end
  end
end
