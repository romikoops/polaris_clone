# frozen_string_literal: true

module Shipments
  class Contact < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    enum contact_type: { consignee: 0,
                         consignor: 1,
                         notifyee: 2 }

    belongs_to :shipment
  end
end

# == Schema Information
#
# Table name: shipments_contacts
#
#  id               :uuid             not null, primary key
#  city             :string
#  company_name     :string
#  contact_type     :integer
#  country_code     :string
#  country_name     :string
#  email            :string
#  first_name       :string
#  geocoded_address :string
#  last_name        :string
#  latitude         :float
#  longitude        :float
#  phone            :string
#  post_code        :string
#  premise          :string
#  province         :string
#  street           :string
#  street_number    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  sandbox_id       :uuid
#  shipment_id      :uuid             not null
#
# Indexes
#
#  index_shipments_contacts_on_sandbox_id   (sandbox_id)
#  index_shipments_contacts_on_shipment_id  (shipment_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
