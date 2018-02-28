class UserLocation < ApplicationRecord
  belongs_to :user
  belongs_to :location
  before_validation :set_primary

  validates :primary, uniqueness: {
    scope: :user,
    message: "'primary' has already been taken by this User"
  }, if: -> { primary == true }

  validates :location, uniqueness: { scope: :user }

  private

  def set_primary
    if user.user_locations.pluck(:primary).none?
      self.primary = true
    end
  end
end
