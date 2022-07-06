# frozen_string_literal: true

module Trucking
  class PostalCode < ApplicationRecord
    belongs_to :country, class_name: "Legacy::Country"
    validates_uniqueness_of :postal_code, scope: :country_id
  end
end

# == Schema Information
#
# Table name: trucking_postal_codes
#
#  id          :uuid             not null, primary key
#  point       :geometry         not null, point, 4326
#  postal_code :citext           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  country_id  :bigint           not null
#
# Indexes
#
#  index_trucking_postal_codes_on_country_id                  (country_id)
#  index_trucking_postal_codes_on_postal_code                 (postal_code)
#  index_trucking_postal_codes_on_postal_code_and_country_id  (postal_code,country_id) UNIQUE
#
