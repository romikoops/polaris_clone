# frozen_string_literal: true

FactoryBot.define do
  factory :distributions_execution, class: "Distributions::Execution" do
    association :action, factory: :distributions_action
    file_id { SecureRandom.uuid }
  end
end
