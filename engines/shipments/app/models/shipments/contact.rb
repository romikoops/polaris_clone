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
#  shipment_id      :uuid             not null
#  sandbox_id       :uuid
#  contact_type     :integer
#  latitude         :float
#  longitude        :float
#  company_name     :string
#  first_name       :string
#  last_name        :string
#  phone            :string
#  email            :string
#  geocoded_address :string
#  street           :string
#  street_number    :string
#  post_code        :string
#  city             :string
#  province         :string
#  premise          :string
#  country_code     :string
#  country_name     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
