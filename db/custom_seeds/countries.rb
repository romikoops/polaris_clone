# frozen_string_literal: true

puts 'Creating countries...'

countries_url = 'https://restcountries.eu/rest/v2/all'
countries_serialized = URI.open(countries_url).read
countries = JSON.parse(countries_serialized)

countries.each do |country|
  country_obj = Legacy::Country.find_or_create_by!(
    name: country['name'],
    code: country['alpha2Code'],
    flag: country['flag']
  )
  country['translations'].each do |lng, tr|
    AlternativeName.find_or_create_by!(
      name: tr,
      locale: lng,
      model: 'Country',
      model_id: country_obj.id.to_s
    )
  end
  country['altSpellings'].each do |spell|
    AlternativeName.find_or_create_by!(
      name: spell,
      model: 'Country',
      model_id: country_obj.id.to_s
    )
  end
end
regions = %w(africa europe americas asia oceania)
regions.each do |region|
  region_url = "https://restcountries.eu/rest/v2/region/#{region}"
  region_serialized = URI.open(region_url).read
  region_countries = JSON.parse(region_serialized)
  region_countries.each do |rc|
    country = Legacy::Country.find_by_name(rc['name'])
    Tag.find_or_create_by!(
      tag_type: 'region',
      name: region.capitalize,
      model: 'Country',
      model_id: country.id
    )
  end
end

region_blocs = %w(EU EFTA CARICOM PA AU USAN EEU AL ASEAN CAIS CEFTA NAFTA SAARC)
region_blocs.each do |region_bloc|
  region_bloc_url = "https://restcountries.eu/rest/v2/regionalbloc/#{region_bloc.downcase}"
  region_bloc_serialized = URI.opeen(region_bloc_url).read
  region_bloc_countries = JSON.parse(region_bloc_serialized)
  region_bloc_countries.each do |rc|
    country = Legacy::Country.find_by_name(rc['name'])
    Tag.find_or_create_by!(
      tag_type: 'region_bloc',
      name: region_bloc,
      model: 'Country',
      model_id: country.id
    )
  end
end
