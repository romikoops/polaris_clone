require 'rails_helper'

module Trucking
  RSpec.describe HubAvailability, class: 'Trucking::HubAvailability', type: :model do
    context 'validations' do
      it 'is valid with valid attributes' do
        expect(FactoryBot.create(:trucking_hub_availability)).to be_valid
      end
    end
  end
end
