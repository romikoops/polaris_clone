FactoryBot.define do
  factory :journey_result, class: "Journey::Result" do
    association :result_set, factory: :journey_result_set
    expiration_date { 4.weeks.from_now }
    issued_at { Time.zone.now }
  end
end
