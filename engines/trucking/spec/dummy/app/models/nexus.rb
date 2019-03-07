# frozen_string_literal: true

class Nexus < ApplicationRecord
  has_many :hubs
  has_many :shipments
  belongs_to :tenant
  belongs_to :country
  geocoded_by :geocoded_address
  reverse_geocoded_by :latitude, :longitude do |location, results|
    if (geo = results.first)
      location.country = Country.find_by(code: geo.country_code)
    end

    location
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  tenant_id  :integer
#  latitude   :float
#  longitude  :float
#  photo      :string
#  country_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
