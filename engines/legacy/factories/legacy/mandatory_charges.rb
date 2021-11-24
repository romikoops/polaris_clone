# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_mandatory_charge, class: "Legacy::MandatoryCharge" do
    pre_carriage { false }
    on_carriage { false }
    import_charges { false }
    export_charges { false }
  end
end

def factory_mandatory_charge(import_charges: false, export_charges: false, pre_carriage: false, on_carriage: false)
  Legacy::MandatoryCharge.find_by(
    import_charges: import_charges, export_charges: export_charges, pre_carriage: pre_carriage, on_carriage: on_carriage
  ) || FactoryBot.create(:legacy_mandatory_charge,
    import_charges: import_charges,
    export_charges: export_charges,
    pre_carriage: pre_carriage,
    on_carriage: on_carriage)
end

# == Schema Information
#
# Table name: mandatory_charges
#
#  id             :bigint           not null, primary key
#  export_charges :boolean
#  import_charges :boolean
#  on_carriage    :boolean
#  pre_carriage   :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
