# frozen_string_literal: true

module Locations
  class Name < ApplicationRecord
    searchkick word_middle: %i(name display_name alternative_names city postal_code), locations: [:location], settings: {blocks: {read_only: false}}
    belongs_to :location, optional: true

    def search_data
      {
        name: [name, transliterated_name],
        display_name: display_name,
        city: city,
        postal_code: postal_code,
        alternative_names: alternative_names,
        location: {lat: point&.y, lon: point&.x}
      }
    end

    def transliterated_name
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
