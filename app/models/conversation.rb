class Conversation < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant
  belongs_to :manager, class_name: 'User', optional: true
  has_many :messages
  def update_unreads
    unread = self.messages.where(read:false).count
    self.unreads = unread
    self.save!
  end
  def update_timestamp
    self.last_updated = DateTime.now
    self.save!
  end
end
