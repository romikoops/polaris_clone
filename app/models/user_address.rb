# frozen_string_literal: true

class UserAddress < Legacy::UserAddress
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
