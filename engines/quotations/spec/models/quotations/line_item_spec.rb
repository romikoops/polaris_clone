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

# == Schema Information
#
# Table name: quotations_line_items
#
#  id                 :uuid             not null, primary key
#  amount_cents       :integer
#  amount_currency    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :bigint
#  tender_id          :uuid
#
# Indexes
#
#  index_quotations_line_items_on_charge_category_id  (charge_category_id)
#  index_quotations_line_items_on_tender_id           (tender_id)
#
