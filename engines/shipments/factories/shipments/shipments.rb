# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_shipment, class: "Shipments::Shipment" do
    association :user, factory: :users_client
    association :organization, factory: :organizations_organization
    association :origin, factory: :routing_terminal
    association :destination, factory: :routing_terminal

    after(:build) do |shipment|
      shipment.consignee = FactoryBot.build(:shipments_contact, :consignee, shipment: shipment)
      shipment.consignor = FactoryBot.build(:shipments_contact, :consignor, shipment: shipment)
      shipment.invoice = FactoryBot.build(:shipments_invoice, shipment: shipment)
      shipment.cargo = FactoryBot.build(:shipments_cargo,
        units: [
          FactoryBot.build(:shipment_lcl_unit)
        ])
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipments
#
#  id                  :uuid             not null, primary key
#  eori                :string
#  incoterm_text       :string
#  notes               :string
#  status              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  destination_id      :uuid             not null
#  old_user_id         :uuid
#  organization_id     :uuid
#  origin_id           :uuid             not null
#  sandbox_id          :uuid
#  shipment_request_id :uuid
#  tenant_id           :uuid
#  user_id             :uuid
#
# Indexes
#
#  index_shipments_shipments_on_destination_id       (destination_id)
#  index_shipments_shipments_on_old_user_id          (old_user_id)
#  index_shipments_shipments_on_organization_id      (organization_id)
#  index_shipments_shipments_on_origin_id            (origin_id)
#  index_shipments_shipments_on_sandbox_id           (sandbox_id)
#  index_shipments_shipments_on_shipment_request_id  (shipment_request_id)
#  index_shipments_shipments_on_tenant_id            (tenant_id)
#  index_shipments_shipments_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (destination_id => routing_terminals.id)
#  fk_rails_...  (old_user_id => tenants_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (origin_id => routing_terminals.id)
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#
