# frozen_string_literal: true

FactoryBot.define do
  factory :sequential_sequence, class: "Sequential::Sequence" do
    name { :shipment_invoice_number }
  end
end

# == Schema Information
#
# Table name: sequential_sequences
#
#  id         :uuid             not null, primary key
#  name       :integer
#  value      :bigint           default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
