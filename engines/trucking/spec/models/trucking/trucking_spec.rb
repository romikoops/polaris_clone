require 'rails_helper'

module Trucking
  RSpec.describe Trucking, class: 'Trucking::Trucking', type: :model do
      it 'is valid with valid attributes' do
        expect(FactoryBot.create(:trucking_trucking)).to be_valid
      end
  end
end
