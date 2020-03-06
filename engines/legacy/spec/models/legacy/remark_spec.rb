# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Remark, type: :model do
    context 'with Quotation' do
      let(:tenant) { FactoryBot.build(:legacy_tenant) }

      let!(:remark_one) { FactoryBot.create(:legacy_remark, tenant: tenant) }
      let(:remark_two) { FactoryBot.build(:legacy_remark, tenant: tenant, body: 'Body of Remark Two') }

      context 'with Different bodies' do
        it 'has different bodies' do
          remark_one.body != remark_two.body
        end
      end

      context 'with Same tenant' do
        it 'has the same tenant' do
          remark_one.tenant == remark_two.tenant
        end
      end

      context 'with Body can be changed' do
        it 'is able to change the body text' do
          remark_two.body = 'New Body'
          remark_two.body == 'New Body'
        end
      end
    end
  end
end
