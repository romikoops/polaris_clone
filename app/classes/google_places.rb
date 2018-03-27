class GooglePlaces
  BASE_URL = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
  API_KEY = ENV["GOOGLE_MAPS_SERVER_API_KEY"]
  def get_place_name(lat_lng, name)
    req_url = "#{BASE_URL}&query=%#{name}%&type=locality&key=#{API_KEY}"
    resp = open(req_url).read
  end
end