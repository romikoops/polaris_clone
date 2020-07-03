# frozen_string_literal: true

FactoryBot.define do
  factory :users_setting, class: 'Users::Settings' do
    currency { 'EUR' }
    association :user, factory: :users_user
  end
end

# == Schema Information
#
# Table name: users_settings
#
#  id         :uuid             not null, primary key
#  currency   :string           default("EUR")
#  language   :string           default("us-en")
#  locale     :string           default("us-en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_users_settings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
