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
#  id           :bigint           not null, primary key
#  user_id      :integer
#  address_id   :integer
#  company_name :string
#  first_name   :string
#  last_name    :string
#  phone        :string
#  email        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alias        :boolean          default(FALSE)
#  sandbox_id   :uuid
#
