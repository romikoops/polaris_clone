# frozen_string_literal: true

module Locations
  class Name < ApplicationRecord
    searchkick word_middle: %i(name display_name city postal_code), settings: {blocks: {read_only: false}}
    belongs_to :location, optional: true
    # validates :osm_id, presence: true

    def names
      [
        name,
        street,
        city,
        postal_code,
        country
      ].compact
    end

    def description
      [
        name,
        street,
        city,
        postal_code,
        country
      ].compact.join(', ')
    end
  end
end

# == Schema Information
#
# Table name: locations_names
#
#  id                :uuid             not null, primary key
#  language          :string
#  location_id       :uuid
#  osm_id            :bigint(8)
#  place_rank        :bigint(8)
#  importance        :bigint(8)
#  osm_type          :string
#  street            :string
#  city              :string
#  osm_class         :string
#  name_type         :string
#  country           :string
#  county            :string
#  state             :string
#  country_code      :string
#  display_name      :string
#  alternative_names :string
#  name              :string
#  point             :geometry({:srid= geometry, 0
#  postal_code       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
