# frozen_string_literal: true

module IDP
  class SamlResponseDecorator < Draper::Decorator
    delegate_all
    delegate :attributes, to: :object

    def profile_attributes
      {
        first_name: attributes.single(:firstName),
        last_name: attributes.single(:lastName),
        phone: attributes.single(:phone),
        external_id: attributes.single(:customerID)
      }
    end

    def company_attributes
      {
        external_id: attributes.single(:companyID),
        name: attributes.single(:companyName)
      }
    end

    def address_attributes
      {
        address_line_1: attributes.single(:address_1),
        address_line_2: attributes.single(:address_2),
        address_line_3: attributes.single(:address_3),
        street: attributes.single(:street),
        street_number: attributes.single(:house_number),
        zip_code: attributes.single(:zip),
        city: attributes.single(:city)
      }
    end

    def country
      attributes.single(:country)
    end

    def groups
      attributes.multi(:groups)
    end

    def email
      attributes.single(:email)
    end
  end
end
