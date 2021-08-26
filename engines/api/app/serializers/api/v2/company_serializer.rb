# frozen_string_literal: true

module Api
  module V2
    class CompanySerializer < Api::ApplicationSerializer
      attributes %i[email name payment_terms phone vat_number]
    end
  end
end
