# frozen_string_literal: true

module Legacy
  class Contact < ApplicationRecord
    self.table_name = "contacts"

    belongs_to :user, class_name: "Organizations::User"
    has_many :shipment_contacts
    belongs_to :address, optional: true
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id             :bigint           not null, primary key
#  alias          :boolean          default(FALSE)
#  company_name   :string
#  email          :string
#  first_name     :string
#  last_name      :string
#  phone          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  address_id     :integer
#  legacy_user_id :integer
#  sandbox_id     :uuid
#  user_id        :uuid
#
# Indexes
#
#  index_contacts_on_sandbox_id  (sandbox_id)
#  index_contacts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
