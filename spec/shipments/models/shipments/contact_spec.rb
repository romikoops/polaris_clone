# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe Contact, type: :model do
    describe 'validity' do
      let(:shipment) { FactoryBot.build(:shipments_shipment) }
      let(:consignor) { FactoryBot.build(:shipments_contact, :consignor, shipment: shipment) }
      let(:consignee) { FactoryBot.build(:shipments_contact, :consignee, shipment: shipment) }

      it 'is valid' do
        expect(consignee).to be_valid
        expect(consignor).to be_valid
      end
    end
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
