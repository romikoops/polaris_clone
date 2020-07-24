# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::PdfService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user_with_profile, organization: organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, user: user, organization: organization) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment) }
  let(:tender_ids) { [shipment.charge_breakdowns.first.tender_id] }
  let(:result) { described_class.new(tender_ids: tender_ids, quotation_id: quotation.id).download }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe '.download' do
    context 'with tender ids' do
      it 'returns the Legacy::File' do
        expect(result.file).to be_attached
      end
    end

    context 'without tender ids' do
      let(:tender_ids) { [] }

      it 'returns the Legacy::File' do
        expect(result.file).to be_attached
      end
    end
  end
end
