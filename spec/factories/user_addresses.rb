# frozen_string_literal: true

FactoryBot.define do
  factory :user_addresses, class: 'UserAddress' do
    association :user
    association :address
  end
end

# == Schema Information
#
# Table name: user_addresses
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  address_id :integer
#  category   :string
#  primary    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
