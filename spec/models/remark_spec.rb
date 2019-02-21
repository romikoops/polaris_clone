# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Remark, type: :model do
  context 'Quotation' do
    let(:tenant) { build(:tenant) }

    let!(:remark_one) { create(:remark, tenant: tenant) }
    let(:remark_two) { build(:remark, tenant: tenant, body: 'Body of Remark Two') }

    context 'Different bodies' do
      it 'has different bodies' do
        remark_one.body != remark_two.body
      end
    end

    context 'Same tenant' do
      it 'has the same tenant' do
        remark_one.tenant == remark_two.tenant
      end
    end

    context 'Body can be changed' do
      it 'is able to change the body text' do
        remark_two.body = 'New Body'
        remark_two.body == 'New Body'
      end
    end
  end
end

# == Schema Information
#
# Table name: remarks
#
#  id          :bigint(8)        not null, primary key
#  tenant_id   :bigint(8)
#  category    :string
#  subcategory :string
#  body        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order       :integer
#
