LOCALITIES = {
  suburb: 'locality_11',
  neighbourhood: 'locality_8',
  city: 'locality_5',
  province: 'locality_8'
}

Location.find_each do |location|
  location_name = {
    language: 'en'
  }
  location.given_attributes.each do |key, value|
    next if !value || key == :bounds
    if [:postal_code, :country].include?(key)
      location_name[key] = value
    else
      location_name[LOCALITIES[key]] = value
    end
  end
  location.location_names.find_or_create_by!(location_name)
end