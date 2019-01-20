# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
  end
end

# == Schema Information
#
# Table name: conversations
#
#  id           :bigint(8)        not null, primary key
#  shipment_id  :integer
#  tenant_id    :integer
#  user_id      :integer
#  manager_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_updated :datetime
#  unreads      :integer
#
