class Agency < ApplicationRecord
  has_many :users
  belongs_to :agency_manager, class_name: "User", optional: true
  belongs_to :tenant
end
