
FactoryBot.define do
  factory :trucking_destination do
  	trait :zipcode do
  		zipcode "15211"
  	end
  	
  	trait :city_name do
  		city_name "Gothenburg"
  	end

  	trait :distance do
  		distance 179
  	end

    trait :zipcode_sequence do
      sequence(:zipcode) do |n|
        (15000 + n - 1).to_s
      end
    end
  end
end