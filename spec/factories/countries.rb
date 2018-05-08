COUNTRIES = [
	{ name: "Sweden", code: "SE", flag: "https://restcountries.eu/data/swe.svg" },
	{ name: "China", code: "CN", flag: "https://restcountries.eu/data/chn.svg" },
	{ name: "Germany", code: "DE", flag: "https://restcountries.eu/data/deu.svg" }
]
FactoryBot.define do
  factory :country do
		[:name, :code, :flag].each do |attribute|
  		sequence(attribute) do |n|
  		  COUNTRIES[(n % COUNTRIES.size) - 1][attribute]
  		end
  	end
  end
end
