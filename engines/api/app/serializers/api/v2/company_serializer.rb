# frozen_string_literal: true

module Api
  module V2
    class CompanySerializer < Api::ApplicationSerializer
      attributes %i[
        id
        name
        email
        payment_terms
        phone
        vat_number
        contact_person_name
        contact_phone
        contact_email
        registration_number
        street_number
        street
        city
        postal_code
        country
        last_activity_at
      ]
    end
  end
end
