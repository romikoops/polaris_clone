# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe LineItem, type: :model do
    subject { FactoryBot.build(:quotations_line_item) }

    context 'with Associations' do
      %i[tender charge_category].each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'with Validity' do
      it { is_expected.to be_valid }
    end
  end
end

# == Schema Information
#
# Table name: quotations_line_items
#
#  id                       :uuid             not null, primary key
#  amount_cents             :integer
#  amount_currency          :string
#  cargo_type               :string
#  original_amount_cents    :integer
#  original_amount_currency :string
#  section                  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  cargo_id                 :integer
#  charge_category_id       :bigint
#  tender_id                :uuid
#
# Indexes
#
#  index_quotations_line_items_on_cargo_type_and_cargo_id  (cargo_type,cargo_id)
#  index_quotations_line_items_on_charge_category_id       (charge_category_id)
#  index_quotations_line_items_on_tender_id                (tender_id)
#
