# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::ProfileService do
  let(:profile) { FactoryBot.build(:profiles_profile) }
  let(:user_double) { instance_double('user') }

  describe '.create_or_update_profile' do
    context 'when creating profiles' do
      let(:attributes) do
        {
          user: user_double,
          first_name: 'Test',
          last_name: 'User',
          company_name: 'ItsMyCargo',
          phone: '123456789'
        }
      end

      it 'creates a new profile as specified' do
        allow(user_double).to receive(:id).and_return(nil)
        expect { described_class.create_or_update_profile(**attributes) }.to(change { Profiles::Profile.count })
      end
    end
  end
end
