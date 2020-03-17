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

      def created_on
        created_at.to_datetime
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                 :uuid             not null, primary key
#  amount_cents       :integer
#  amount_currency    :string
#  carrier_name       :string
#  load_type          :string
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  destination_hub_id :integer
#  origin_hub_id      :integer
#  quotation_id       :uuid
#  tenant_vehicle_id  :bigint
#
# Indexes
#
#  index_quotations_tenders_on_destination_hub_id  (destination_hub_id)
#  index_quotations_tenders_on_origin_hub_id       (origin_hub_id)
#  index_quotations_tenders_on_quotation_id        (quotation_id)
#  index_quotations_tenders_on_tenant_vehicle_id   (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
