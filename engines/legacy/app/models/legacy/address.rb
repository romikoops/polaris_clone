module Legacy
  class Address < ApplicationRecord
    self.table_name = 'addresses'
    has_one :legacy_hub
    belongs_to :country, class_name: 'Legacy::Country', optional: true
    geocoded_by :geocoded_address
    # before_validation :sanitize_zip_code!

    reverse_geocoded_by :latitude, :longitude do |address, results|
      if geo = results.first
        premise_data = geo.address_components.find do |address_component|
          address_component['types'] == ['premise']
        end || {}
        address.premise          = premise_data['long_name']
        address.street_number    = geo.street_number
        address.street           = geo.route
        address.street_address   = geo.street_number.to_s + ' ' + geo.route.to_s
        address.geocoded_address = geo.address
        address.city             = geo.city
        address.zip_code         = geo.postal_code
  
        address.country          = Country.find_by(code: geo.country_code)
      end
  
      address
    end
  end
end
