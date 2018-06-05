# frozen_string_literal: true

FactoryBot.define do
  factory :mandatory_charge do
    pre_carriage false
    on_carriage false
    import_charges false
    export_charges false    
  end
end
