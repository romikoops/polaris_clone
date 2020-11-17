# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::ActiveClientCount, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:clients) do
    %w[John Jane].map do |name|
      user = FactoryBot.create(:organizations_user, organization: organization, last_login_at: Time.zone.now)
      FactoryBot.create(:profiles_profile, user_id: user.id, first_name: name)
      user
    end
  end
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) { described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:profiles_profile, user_id: user.id)
  end

  context 'with two active clients' do
    describe '.data' do
      it 'returns a the clients count for the time period' do
        expect(result).to eq(clients.length)
      end
    end
  end

  context 'with one non-active client' do
    before do
      user = FactoryBot.create(:organizations_user,
                               organization: organization,
                               last_login_at: Time.zone.now - 2.months)
      FactoryBot.create(:profiles_profile, user_id: user.id, first_name: 'Ron')
    end

    describe '.data' do
      it 'returns a the clients count for the time period' do
        expect(result).to eq(clients.length)
      end
    end
  end
end
