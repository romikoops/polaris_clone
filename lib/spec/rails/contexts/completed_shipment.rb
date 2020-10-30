# frozen_string_literal: true

RSpec.shared_context "completed_shipment" do
  include_context "completed_quotation"

  let!(:shipment) do
    FactoryBot.create(:completed_legacy_shipment,
      organization: organization,
      user: user,
      trip: trip,
      load_type: load_type,
      with_breakdown: true,
      with_tenders: true,
      with_full_breakdown: true)
  end
end
