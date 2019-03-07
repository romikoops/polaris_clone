class Address < ApplicationRecord
  has_many :user_addresses
  has_many :users, through: :user_addresses, dependent: :destroy
  has_many :shipments
  has_many :contacts
  has_many :ports, foreign_key: :nexus_id
  has_many :ports
  has_one :hub
  has_many :routes
  has_many :stops, through: :hubs
  belongs_to :country, optional: true
end