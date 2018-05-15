
FactoryBot.define do
  factory :trucking_destination do
  	trait :zipcode do
  		zipcode "15211"
  	end
  	
  	trait :with_geometry do
  		association :geometry
  	end

  	trait :distance do
  		distance 179
  	end

    trait :zipcode_sequence do
      sequence(:zipcode) do |n|
        (15000 + n - 1).to_s
      end
    end

    country_code "SE"
  end
end