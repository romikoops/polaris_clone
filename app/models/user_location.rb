class UserLocation < ApplicationRecord
   CATEGORIES = %w(main secondary)

  belongs_to :user
  belongs_to :location

 #  validates :category, presence: true, inclusion: CATEGORIES
  # validates :category, uniqueness: { 
  #   scope: :user, 
  #   message: "'main' has already been taken by this User"
  # }, if: -> { category == 'main' }

  # validates :location, uniqueness: { scope: :user }
end
