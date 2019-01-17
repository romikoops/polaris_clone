# frozen_string_literal: true

module Locations
  class Name < ApplicationRecord
    include PgSearch

    validates :osm_id, uniqueness: {
      scope: %i(
        language
        street
        city
        country
        country_code
        display_name
        alternative_names
        name
        point
        postal_code
      ),
      message: ->(record, _) { "is a duplicate for the names: #{record.names.to_s.tr('"', "'")}" }
    }

    pg_search_scope :autocomplete,
                    against: %i(
                      street
                      city
                      country
                      country_code
                      display_name
                      alternative_names
                      name
                      postal_code
                      name
                    ),
                    ignoring: :accents,
                    using: {
                      tsearch: { prefix: true }
                    }

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
