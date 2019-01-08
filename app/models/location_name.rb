class LocationName < ApplicationRecord
  belongs_to :location
  include PgSearch

  validates :location_id, uniqueness: {
    scope:   %i(locality_2 locality_3 locality_4 locality_5 locality_6 locality_7 locality_8 locality_9 locality_10 locality_11 country),
    message: ->(obj, _) { "is a duplicate for the names: #{obj.names.log_format}" }
  }

  pg_search_scope :autocomplete,
                  :against => %i(locality_2 locality_3 locality_4 locality_5 locality_6 locality_7 locality_8 locality_9 locality_10 locality_11 country),
                  :using => {
                    :tsearch => {:prefix => true}
                  }
end

# == Schema Information
#
# Table name: location_names
#
#  id          :bigint(8)        not null, primary key
#  language    :string
#  locality_2  :string
#  locality_3  :string
#  locality_4  :string
#  locality_5  :string
#  locality_6  :string
#  locality_7  :string
#  locality_8  :string
#  locality_9  :string
#  locality_10 :string
#  locality_11 :string
#  country     :string
#  postal_code :string
#  name        :string
#  location_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
