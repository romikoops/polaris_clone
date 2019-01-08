# frozen_string_literal: true

class Port < ApplicationRecord
  belongs_to :nexus
  belongs_to :address
  belongs_to :country
end

# == Schema Information
#
# Table name: ports
#
#  id         :bigint(8)        not null, primary key
#  country_id :integer
#  name       :string
#  latitude   :decimal(, )
#  longitude  :decimal(, )
#  telephone  :string
#  web        :string
#  code       :string
#  nexus_id   :integer
#  address_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
