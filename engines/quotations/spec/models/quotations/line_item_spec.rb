# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe LineItem, type: :model do
    subject { described_class.new }

    context 'Associations' do
      %i(tender charge_category).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end
  end
end
