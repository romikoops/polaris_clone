# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_vehicle, class: 'Legacy::Vehicle' do
    name { 'standard' }
    mode_of_transport { 'ocean' }
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
