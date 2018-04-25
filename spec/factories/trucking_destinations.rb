
FactoryBot.define do
  factory :trucking_destination do
  	trait :zipcode do
  		zipcode "15211"
  	end
  	zipcode unless zipcode.nil?
  end
end