# frozen_string_literal: true

module Ledger
  class Location < ApplicationRecord
    validates :name, uniqueness: { allow_blank: true }
    validates :geodata, presence: true
    validates :country, inclusion: { in: Carmen::Country.all.map(&:code), allow_blank: true }
    validates :country, presence: true, if: ->(l) { l.region.present? }
    validates :region, presence: true, if: ->(l) { l.country.present? }
    validate :region_correctness, if: ->(l) { l.country.present? }

    private

    def region_correctness
      return if region.blank?

      carmen_country = country.presence && Carmen::Country.alpha_2_coded(country)
      return if carmen_country.blank?
      return if carmen_country.subregions.map(&:code).include?(region)

      errors.add(:region, "unknown region ('#{region}') for the country ('#{country}')")
    end
  end
end

# == Schema Information
#
# Table name: ledger_locations
#
#  id         :uuid             not null, primary key
#  country    :string
#  geodata    :geometry         not null, multipolygon, 4326
#  name       :string
#  region     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ledger_locations_on_name  (name) UNIQUE
#
