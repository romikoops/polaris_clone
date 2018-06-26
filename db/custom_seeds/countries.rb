# frozen_string_literal: true

puts 'Creating countries...'

countries_url = 'https://restcountries.eu/rest/v2/all'
countries_serialized = open(countries_url).read
countries = JSON.parse(countries_serialized)

countries.each do |country|
  Country.find_or_create_by!(
    name: country['name'],
    code: country['alpha2Code'],
    flag: country['flag']
  )
end
