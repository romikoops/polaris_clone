# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_data, class: "Hash" do
    skip_create

    transient do
      hub { FactoryBot.create(:legacy_hub) }
    end

    initialize_with { data.with_indifferent_access }

    trait :all_fcl do
      data do
        {
          pre: {
            hub.id => {
              trucking_charge_data: {
                fcl_20: {container_6353: {value: 0.395e3, currency: "EUR"},
                         total: {value: 0.395e3, currency: "EUR"},
                         metadata_id: "fc72b64d-be92-42f2-a2fc-41593d8008c3"},
                fcl_40: {container_6354: {value: 0.395e3, currency: "EUR"},
                         total: {value: 0.395e3, currency: "EUR"},
                         metadata_id: "c1e4d066-2539-4879-831d-80f63e2363fc"},
                fcl_40_hq: {container_6355: {value: 0.395e3, currency: "EUR"},
                            total: {value: 0.395e3, currency: "EUR"},
                            metadata_id: "f5128e81-387c-4258-b160-0b73fe7cf576"}
              }
            }
          }
        }
      end
    end
    trait :lcl do
      data do
        {
          pre: {
            hub.id => {
              trucking_charge_data: {
                lcl: {
                  stackable: {
                    value: 0.10175e3,
                    currency: "USD"
                  },
                  non_stackable: {},
                  total: {
                    value: 0.10175e3,
                    currency: "USD"
                  },
                  metadata_id: "3b57c607-35de-433f-a29b-ea9c89e07ddd"
                }
              }
            }
          }
        }
      end
    end

    factory :lcl_trucking_data, traits: [:lcl]
    factory :all_fcl_trucking_data, traits: [:all_fcl]
  end
end
