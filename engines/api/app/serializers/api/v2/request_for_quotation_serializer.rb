# frozen_string_literal: true

module Api
  module V2
    class RequestForQuotationSerializer < Api::ApplicationSerializer
      attributes %i[id full_name email phone company_name organization_id query_id]
    end
  end
end
