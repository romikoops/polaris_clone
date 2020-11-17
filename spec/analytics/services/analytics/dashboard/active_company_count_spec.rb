# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::ActiveCompanyCount, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:result) { described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date) }

  before do
    ::Organizations.current_id = organization.id
    user = FactoryBot.create(:organizations_user,
                             organization: organization,
                             last_login_at: 2.days.ago)
    FactoryBot.create(:companies_membership, company: company, member: user)
  end

  context 'with one active company' do
    describe '.data' do
      it 'returns the active company count for the time period' do
        expect(result).to eq(1)
      end
    end
  end
end
