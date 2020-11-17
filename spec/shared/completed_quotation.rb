# frozen_string_literal: true

RSpec.shared_context "completed_quotation" do
  include_context "organization"
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
  let(:trip) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, code: "saco", name: "SACO") }
  let(:load_type) { "cargo_item" }
  let(:tender_count) { 1 }
  let!(:shipment) do
    FactoryBot.create(:complete_legacy_shipment,
      organization: organization, user: user, trip: trip, load_type: load_type,
      with_breakdown: true, with_tenders: true, with_full_breakdown: true, breakdown_count: tender_count)
  end
  let(:quotations_quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment.id) }
  let(:tender_ids) do
    [shipment.charge_breakdowns.first.tender_id]
  end
  let(:scope_content) { {show_chargeable_weight: true, values: {weight: {unit: "kg", decimals: 3}}} }

  before do
    quotations_quotation.tenders.each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end
end
