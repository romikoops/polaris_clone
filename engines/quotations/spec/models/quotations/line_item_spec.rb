# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe LineItem, type: :model do
    subject { FactoryBot.build :quotations_line_item }

    context 'Associations' do
      %i(tender charge_category).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end
  end
end
