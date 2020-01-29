require 'rails_helper'

module Trucking
  RSpec.describe Scope, type: :model do
    let(:scope) { FactoryBot.create(:trucking_scope) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:trucking_scope)).to be_valid
      end
  end
end

# == Schema Information
#
# Table name: trucking_scopes
#
#  id          :uuid             not null, primary key
#  cargo_class :string
#  carriage    :string
#  load_type   :string
#  truck_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  courier_id  :uuid
#
