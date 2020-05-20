# frozen_string_literal: true

module Api
  class PaginationDecorator < Draper::CollectionDecorator
    delegate :total_pages

    def links
      context[:links]
    end

    def page
      object.current_page.to_i
    end

    def per_page
      object.limit_value
    end
  end
end
