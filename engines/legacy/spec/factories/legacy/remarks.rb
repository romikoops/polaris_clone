# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_remark, class: 'Legacy::Remark' do
    body { 'Some Remark' }
    association :tenant
    category { 'Quotation' }
    subcategory { 'Shipment' }
  end
end

# == Schema Information
#
# Table name: remarks
#
#  id          :bigint           not null, primary key
#  body        :string
#  category    :string
#  order       :integer
#  subcategory :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#  tenant_id   :bigint
#
# Indexes
#
#  index_remarks_on_sandbox_id  (sandbox_id)
#  index_remarks_on_tenant_id   (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
