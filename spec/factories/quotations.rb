# frozen_string_literal: true

FactoryBot.define do
  factory :quotation do
    association :user, factory: :organizations_user
    transient do
      shipment_count { 1 }
      load_type { "cargo_item" }
    end

    target_email { "john@example.test" }
    name { "NAME" }
    billing { :external }

    after(:build) do |quotation, evaluator|
      original_shipment = create(:shipment,
        user: quotation.user,
        organization: quotation.user.organization,
        load_type: evaluator.load_type,
        with_breakdown: true)
      quotation.shipments = create_list(:shipment, evaluator.shipment_count,
        user: quotation.user,
        organization: quotation.user.organization,
        load_type: evaluator.load_type,
        with_breakdown: true)
      quotation.original_shipment_id = original_shipment.id
    end
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  distinct_id          :uuid
#  old_user_id          :integer
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#  index_quotations_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_  (user_id => users_users.id)
#
