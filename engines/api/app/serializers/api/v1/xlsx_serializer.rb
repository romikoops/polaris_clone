# frozen_string_literal: true

module Api
  module V1
    class XlsxSerializer < Api::ApplicationSerializer
      attribute :url do |object, params|
        params.dig(:url)
      end
    end
  end
end
