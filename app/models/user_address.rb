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
#  category   :string
#  deleted_at :datetime
#  primary    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_user_addresses_on_deleted_at  (deleted_at)
#
