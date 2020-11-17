FactoryBot.define do
  factory :authentication_user, class: "Authentication::User", parent: :users_user do
    type { "Organizations::User" }

    trait :organizations_user do
      type { "Organizations::User" }
    end

    trait :active do
      activation_state { "active" }
    end

    trait :users_user do
      type { "Users::User" }
    end
  end
end
