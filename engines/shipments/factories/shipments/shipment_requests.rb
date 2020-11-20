# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_shipment_request, class: "Shipments::ShipmentRequest" do
    association :user, factory: :organizations_user
    association :organization, factory: :organizations_organization
    association :tender, factory: :quotations_tender

    status { :created }
    submitted_at { Time.current }
    eori { "eori text" }
    etd { Time.current + 1.month }
    eta { Time.current + 2.months }
    sequence(:ref_number) { |n| "#{SecureRandom.hex}#{n}" }
  end
end

# == Schema Information
#
# Table name: shipments_shipment_requests
#
#  id              :uuid             not null, primary key
#  cargo_notes     :string
#  eori            :string
#  eta             :datetime
#  etd             :datetime
#  incoterm_text   :string
#  notes           :string
#  ref_number      :string           not null
#  status          :string
#  submitted_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  old_user_id     :uuid
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :uuid
#  tender_id       :uuid             not null
#  user_id         :uuid
#
# Indexes
#
#  index_shipments_shipment_requests_on_old_user_id      (old_user_id)
#  index_shipments_shipment_requests_on_organization_id  (organization_id)
#  index_shipments_shipment_requests_on_sandbox_id       (sandbox_id)
#  index_shipments_shipment_requests_on_tenant_id        (tenant_id)
#  index_shipments_shipment_requests_on_tender_id        (tender_id)
#  index_shipments_shipment_requests_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (old_user_id => tenants_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#  fk_rails_...  (tender_id => quotations_tenders.id)
#
