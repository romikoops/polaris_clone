# frozen_string_literal: true

module Legacy
  class Contact < ApplicationRecord
    self.table_name = 'contacts'

    belongs_to :user
    has_many :shipment_contacts
    belongs_to :address, optional: true
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id                                :bigint           not null, primary key
#  alias                             :boolean          default(FALSE)
#  company_name                      :string
#  email(MASKED WITH EmailAddress)   :string
#  first_name(MASKED WITH FirstName) :string
#  last_name(MASKED WITH LastName)   :string
#  phone(MASKED WITH Phone)          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  address_id                        :integer
#  sandbox_id                        :uuid
#  user_id                           :integer
#
# Indexes
#
#  index_contacts_on_sandbox_id  (sandbox_id)
#
