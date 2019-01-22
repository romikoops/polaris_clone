# frozen_string_literal: true

FactoryBot.define do
  factory :mandatory_charge do
    pre_carriage { false }
    on_carriage { false }
    import_charges { false }
    export_charges { false }
  end
end

# == Schema Information
#
# Table name: mandatory_charges
#
#  id             :bigint(8)        not null, primary key
#  pre_carriage   :boolean
#  on_carriage    :boolean
#  import_charges :boolean
#  export_charges :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
