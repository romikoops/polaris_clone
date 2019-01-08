# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant
  belongs_to :manager, class_name: 'User', optional: true
  has_many :messages
  def update_unreads
    unread = messages.where(read: false).count
    self.unreads = unread
    save!
  end

  def update_timestamp
    self.last_updated = DateTime.now
    save!
  end

  def self.clear_old_conversations
    all.each do |convo|
      convo.destroy if convo.shipment.nil?
    end
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
