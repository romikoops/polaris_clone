# frozen_string_literal: true

require 'rails_helper'

module Trucking
  RSpec.describe TypeAvailability, class: 'Trucking::TypeAvailability', type: :model do
    it 'is valid with valid attributes' do
      expect(FactoryBot.build(:trucking_type_availability)).to be_valid
    end

    it 'creates all permutations in create_all!' do
      described_class.create_all!
      expect(described_class.count).to eq(48)
    end

    it 'is unique' do
      described_class.create_all!

      expect(FactoryBot.build(:trucking_type_availability)).not_to be_valid
    end
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  carriage     :string
#  load_type    :string
#  query_method :integer
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_type_availabilities_on_sandbox_id  (sandbox_id)
#
