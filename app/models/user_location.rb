# frozen_string_literal: true

class UserLocation < ApplicationRecord
  belongs_to :user
  belongs_to :location
  before_validation :set_primary

  validates :primary, uniqueness: {
    scope: :user,
    message: "'primary' has already been taken by this User"
  }, if: -> { primary }

  validates :location, uniqueness: { scope: :user }

  private

  def set_primary
    self.primary = true if user.user_locations.pluck(:primary).none?
  end
end
