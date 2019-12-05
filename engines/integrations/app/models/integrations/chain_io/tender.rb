# frozen_string_literal: true

module Integrations
  module ChainIo
    class Tender < Quotations::Tender
      belongs_to :quotation

      def origin
        {
          unlocode: origin_hub.locode || '',
          description: "#{origin_hub.address.city}, #{origin_hub.address.country.code}"
        }
      end

      def destination
        {
          unlocode: destination_hub.locode || '',
          description: "#{destination_hub.address.city}, #{destination_hub.address.country.code}"
        }
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                 :uuid             not null, primary key
#  tenant_vehicle_id  :bigint
#  origin_hub_id      :integer
#  destination_hub_id :integer
#  carrier_name       :string
#  name               :string
#  load_type          :string
#  amount_cents       :integer
#  amount_currency    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  quotation_id       :uuid
#
