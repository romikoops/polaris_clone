require 'rails_helper'

module Trucking
  RSpec.describe Scope, type: :model do
    let(:scope) { FactoryBot.create(:trucking_scope) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:trucking_scope)).to be_valid
      end
  end
end
