# frozen_string_literal: true

class UserAddress < ApplicationRecord
  belongs_to :user
  belongs_to :address
  before_validation :set_primary

  validates :primary, uniqueness: {
    scope:   :user,
    message: "'primary' has already been taken by this User"
  }, if: -> { primary }

  validates :address, uniqueness: { scope: :user }

  private

  def set_primary
    self.primary = true if user.user_addresses.pluck(:primary).none?
  end
end
