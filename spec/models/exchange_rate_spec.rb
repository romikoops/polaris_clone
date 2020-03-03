# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  it 'creates a valid object' do
    expect(build(:exchange_rate)).to be_valid
  end
end

# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string
#  rate       :decimal(, )
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_exchange_rates_on_from  (from)
#  index_exchange_rates_on_to    (to)
#
