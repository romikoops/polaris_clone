# frozen_string_literal: true

module Api
  class ApplicationSerializer < ActiveModel::Serializer
    def quotation_tool?
      scope['open_quotation_tool'] || scope['closed_quotation_tool']
    end
  end
end
