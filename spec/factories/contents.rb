# frozen_string_literal: true

FactoryBot.define do
  factory :content do
    component { 'main' }
    section { 'main' }
    text { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }

    index { 0 }
  end
end

# == Schema Information
#
# Table name: contents
#
#  id         :bigint           not null, primary key
#  text       :jsonb
#  component  :string
#  section    :string
#  index      :integer
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
