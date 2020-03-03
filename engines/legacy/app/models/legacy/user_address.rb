# frozen_string_literal: true

module Legacy
  class UserAddress < ApplicationRecord
    self.table_name = 'user_addresses'
    belongs_to :user, class_name: 'Legacy::User'
    belongs_to :address, class_name: 'Legacy::Address'
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
