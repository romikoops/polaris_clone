# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::PdfService do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, with_profile: true) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, tenant: tenant, user: user) }
  let(:tenders) { [{ id: shipment.charge_breakdowns.first.tender_id }] }

  before { FactoryBot.create(:tenants_theme, tenant: tenants_tenant) }

  describe '.download' do
    let(:service) { described_class.new(tenders: tenders) }

    it 'returns the Legacy::File' do
      result = service.download
      aggregate_failures do
        expect(result).to be_a(Legacy::File)
        expect(result.file).to be_attached
      end
    end
  end
end
