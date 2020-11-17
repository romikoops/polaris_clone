# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Layover, type: :model do
    describe 'it creates a valid object' do
      it 'is valid' do
        expect(FactoryBot.build(:legacy_layover)).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: layovers
#
#  id           :bigint           not null, primary key
#  closing_date :datetime
#  eta          :datetime
#  etd          :datetime
#  stop_index   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  itinerary_id :integer
#  sandbox_id   :uuid
#  stop_id      :integer
#  trip_id      :integer
#
# Indexes
#
#  index_layovers_on_sandbox_id  (sandbox_id)
#  index_layovers_on_stop_id     (stop_id)
#
