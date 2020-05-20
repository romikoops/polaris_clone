# frozen_string_literal: true

module Api
  class ApplicationDecorator < Draper::Decorator
    def self.collection_decorator_class
      PaginationDecorator
    end
  end
end
