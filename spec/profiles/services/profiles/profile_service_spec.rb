# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ProfileService do
  let(:profile) { FactoryBot.build(:profiles_profile) }
  let(:user) { FactoryBot.create(:organizations_user) }

  describe '.create_or_update_profile' do
    context 'when no profile exists for the user' do
      let(:attributes) do
        {
          user: user,
          first_name: 'Test',
          last_name: 'User',
          company_name: 'ItsMyCargo',
          phone: '123456789'
        }
      end

      it 'creates a new profile as specified' do
        expect { described_class.create_or_update_profile(**attributes) }.to(change { Profiles::Profile.count })
      end
    end

    context 'when a profile already exists for the user' do
      let(:attributes) do
        {
          user: user,
          first_name: 'Test',
          last_name: 'User',
          company_name: 'ItsMyCargo',
          phone: '123456789'
        }
      end

      before do
        FactoryBot.create(:profiles_profile, user: user)
      end

      it 'creates a new profile as specified' do
        expect { described_class.create_or_update_profile(**attributes) }.not_to(change { Profiles::Profile.count })
      end
    end
  end
end
