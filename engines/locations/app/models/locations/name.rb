# frozen_string_literal: true

module Locations
  class Name < ApplicationRecord
    searchkick word_middle: %i[name display_name alternative_names city postal_code country_code],
               geo_shape: [:point],
               settings: {blocks: {read_only: false}}
    belongs_to :location, optional: true

    def search_data
      {
        name: [name, transliterated_name],
        display_name: display_name,
        city: city,
        postal_code: postal_code,
        alternative_names: alternative_names,
        location: {lat: point&.y, lon: point&.x},
        country_code: country_code
      }
    end

    def transliterated_name
      return if name.nil?

      locale = I18n.available_locales.find { |l| l[/#{country_code}/i] }
      I18n.with_locale(locale) do
        ActiveSupport::Inflector.transliterate(name)
      end
    end
  end
end

# == Schema Information
#
# Table name: locations_names
#
#  id                :uuid             not null, primary key
#  alternative_names :string
#  city              :string
#  country           :string
#  country_code      :string
#  county            :string
#  display_name      :string
#  importance        :bigint
#  language          :string
#  locode            :string
#  name              :string
#  name_type         :string
#  osm_class         :string
#  osm_type          :string
#  place_rank        :bigint
#  point             :geometry         geometry, 0
#  postal_code       :string
#  state             :string
#  street            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  location_id       :uuid
#  osm_id            :bigint
#
# Indexes
#
#  index_locations_names_on_locode    (locode)
#  index_locations_names_on_osm_id    (osm_id)
#  index_locations_names_on_osm_type  (osm_type)
#  locations_names_to_tsvector_idx1   (to_tsvector('english'::regconfig, (country)::text)) USING gin
#  locations_names_to_tsvector_idx10  (to_tsvector('english'::regconfig, (city)::text)) USING gin
#  locations_names_to_tsvector_idx3   (to_tsvector('english'::regconfig, (language)::text)) USING gin
#  locations_names_to_tsvector_idx4   (to_tsvector('english'::regconfig, (osm_id)::text)) USING gin
#  locations_names_to_tsvector_idx5   (to_tsvector('english'::regconfig, (country_code)::text)) USING gin
#  locations_names_to_tsvector_idx6   (to_tsvector('english'::regconfig, (display_name)::text)) USING gin
#  locations_names_to_tsvector_idx7   (to_tsvector('english'::regconfig, (name)::text)) USING gin
#  locations_names_to_tsvector_idx8   (to_tsvector('english'::regconfig, (alternative_names)::text)) USING gin
#  locations_names_to_tsvector_idx9   (to_tsvector('english'::regconfig, (postal_code)::text)) USING gin
#  uniq_index_1                       (language,osm_id,street,country,country_code,display_name,name,postal_code) UNIQUE
#
