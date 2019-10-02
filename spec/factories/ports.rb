# frozen_string_literal: true

FactoryBot.define do
  factory :port do
  end
end

# == Schema Information
#
# Table name: ports
#
#  id         :bigint           not null, primary key
#  country_id :integer
#  name       :string
#  latitude   :decimal(, )
#  longitude  :decimal(, )
#  telephone  :string
#  web        :string
#  code       :string
#  nexus_id   :integer
#  address_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
