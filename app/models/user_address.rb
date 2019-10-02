# frozen_string_literal: true

class UserAddress < ApplicationRecord
  belongs_to :user
  belongs_to :address
  before_validation :set_primary

  validates :primary, uniqueness: {
    scope: :user,
    message: "'primary' has already been taken by this User"
  }, if: -> { primary }

  validates :address, uniqueness: { scope: :user }

  private

  def set_primary
    self.primary = user.user_addresses.pluck(:primary).none?
  end
end

# == Schema Information
#
# Table name: user_addresses
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  address_id :integer
#  category   :string
#  primary    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
