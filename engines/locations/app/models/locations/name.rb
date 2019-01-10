# frozen_string_literal: true

module Locations
  class Name < ApplicationRecord
    belongs_to :location
    include PgSearch

    validates :location, uniqueness: {
      scope: %i(locality_2
                locality_3
                locality_4
                locality_5
                locality_6
                locality_7
                locality_8
                locality_9
                locality_10
                locality_11
                country
                postal_code
                name
                language),
      message: ->(record, _) { "is a duplicate for the names: #{record.names.to_s.tr('"', "'")}" }
    }

    pg_search_scope :autocomplete,
                    against: %i(locality_2
                                locality_3
                                locality_4
                                locality_5
                                locality_6
                                locality_7
                                locality_8
                                locality_9
                                locality_10
                                locality_11
                                country
                                postal_code
                                name),
                    using: {
                      tsearch: { prefix: true }
                    }

    def names
      [
        country,
        locality_2,
        locality_3,
        locality_4,
        locality_5,
        locality_6,
        locality_7,
        locality_8,
        locality_9,
        locality_10,
        locality_11
      ].reverse.compact
    end

    def description
      [
        country,
        locality_2,
        locality_3,
        locality_4,
        locality_5,
        locality_6,
        locality_7,
        locality_8,
        locality_9,
        locality_10,
        locality_11
      ].reverse.compact.join(', ')
    end

  
  end
end

# == Schema Information
#
# Table name: locations_names
#
#  id                :uuid             not null, primary key
#  language          :string
#  osm_id            :integer
#  place_rank        :integer
#  osm_type          :string
#  street            :string
#  city              :string
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
