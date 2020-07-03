FactoryBot.define do
  factory :authentication_user, class: "Authentication::User", parent: :users_user do
    trait :organizations_user do
      type { "Organizations::User" }
    end

    trait :users_user do
      type { "Users::User" }
    end
  end
end
