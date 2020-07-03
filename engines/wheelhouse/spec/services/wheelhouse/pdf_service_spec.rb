# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::PdfService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user_with_profile, organization: organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, user: user, organization: organization) }
  let(:tenders) { [{ id: shipment.charge_breakdowns.first.tender_id }] }
  let(:result) { described_class.new(tenders: tenders).download }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe '.download' do
    it 'returns the Legacy::File' do
      expect(result.file).to be_attached
    end
  end
end
