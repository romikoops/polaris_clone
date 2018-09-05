# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant
  belongs_to :manager, class_name: "User", optional: true
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
    self.all.each do |convo|
      if convo.shipment.nil?
        convo.destroy
      end
    end
  end

end
