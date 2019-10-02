# frozen_string_literal: true

FactoryBot.define do
  factory :alternative_name do
  end
end

# == Schema Information
#
# Table name: alternative_names
#
#  id         :bigint           not null, primary key
#  model      :string
#  model_id   :string
#  name       :string
#  locale     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
