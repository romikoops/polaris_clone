# frozen_string_literal: true

module Legacy
  class UserAddress < ApplicationRecord
    self.table_name = 'user_addresses'
    belongs_to :user, class_name: 'Organizations::User'
    belongs_to :address, class_name: 'Legacy::Address'

    before_validation :set_primary

    validates :primary, uniqueness: { scope: :user }, if: -> { primary }
    validates :address, uniqueness: { scope: :user }

    private

    def set_primary
      self.primary = UserAddress.where(user_id: user_id, primary: true).none?
    end
  end
end

# == Schema Information
#
# Table name: user_addresses
#
#  id             :bigint           not null, primary key
#  category       :string
#  deleted_at     :datetime
#  primary        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  address_id     :integer
#  legacy_user_id :integer
#  user_id        :uuid
#
# Indexes
#
#  index_user_addresses_on_deleted_at  (deleted_at)
#  index_user_addresses_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
