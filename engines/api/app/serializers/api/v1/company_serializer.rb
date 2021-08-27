# frozen_string_literal: true

module Api
  module V1
    class CompanySerializer < Api::ApplicationSerializer
      attributes %i[id email name payment_terms phone vat_number]
    end
  end
end
