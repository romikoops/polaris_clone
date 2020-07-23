# frozen_string_literal: true

module Api
  module Pagination
    extend ActiveSupport::Concern

    included do
      def paginate(collection)
        paginated = collection.paginate_api(pagination_params[:page])
          .per(pagination_params[:per_page] || 10)

        paginated
      end

      def pagination_links(collection)
        links = {
          first: nil,
          prev: page_url(collection.prev_page),
          next: page_url(collection.next_page),
          last: nil
        }

        if collection.total_pages > 1
          links[:first] = page_url(1)
          links[:last] = page_url(collection.total_pages)
        end

        links
      end
    end

    def pagination_params
      params.permit(:page, :per_page)
    end

    def page_url(page)
      return nil unless page

      url_for(request.query_parameters.merge(page: page))
    end
  end
end
