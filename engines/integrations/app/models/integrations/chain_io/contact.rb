# frozen_string_literal: true

module Integrations
  module ChainIo
    class Contact < SimpleDelegator
      def format
        {
          source_party_id: id,
          target_party_id: tms_id || "",
          name: full_name,
          address_1: address_1,
          address_2: street_number || "",
          city: city || "",
          state: "",
          state_name: "",
          country: country_code,
          country_name: "",
          postal_code: postal_code || "",
          phone_number: phone,
          unlocode: ""
        }
      end

      def full_name
        [first_name, last_name].compact.join(" ")
      end

      def address_1
        [street, street_number].compact.join(" ")
      end
    end
  end
end
