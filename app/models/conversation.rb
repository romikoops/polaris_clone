class Conversation < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
  belongs_to :tenant
  belongs_to :manager, class_name: 'User', optional: true
  has_many :messages
end
