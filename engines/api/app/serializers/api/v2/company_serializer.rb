# frozen_string_literal: true

module Api
  module V2
    class CompanySerializer < Api::ApplicationSerializer
      attributes %i[id email name payment_terms phone vat_number contact_person_name contact_phone contact_email registration_number]
    end
  end
end
