# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe User, type: :model do
    context 'legacy_sync' do
      let(:legacy_user) { FactoryBot.build(:legacy_user) }
      it 'creates from legacy' do
        user = described_class.create_from_legacy(legacy_user)
        expect(user).to be_valid
      end
    end
  end
end
