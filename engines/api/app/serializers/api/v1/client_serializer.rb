# frozen_string_literal: true

module Api
  module V1
    class ClientSerializer < Api::ApplicationSerializer
      attributes %i[email organization_id first_name last_name phone company_name payment_terms company_id]
    end
  end
end
