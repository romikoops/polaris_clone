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
        last_activity_at
      ]

      attribute :address do |company|
        company_address = company.address
        if company_address.present?
          %i[street street_number postal_code city country].inject({}) do |result, attribute|
            result.merge(attribute.to_s.camelize(:lower) => company.send(attribute))
          end
        end
      end
    end
  end
end
