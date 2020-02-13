# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
  end
end

# == Schema Information
#
# Table name: conversations
#
#  id           :bigint           not null, primary key
#  last_updated :datetime
#  unreads      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  manager_id   :integer
#  shipment_id  :integer
#  tenant_id    :integer
#  user_id      :integer
#
# Indexes
#
#  index_conversations_on_tenant_id  (tenant_id)
#
