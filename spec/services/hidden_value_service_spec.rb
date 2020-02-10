# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HiddenValueService, type: :service do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:scope) { create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: {}) }
  let(:klass) { described_class.new(user: user) }

  context 'with hidden grand totals' do
    before do
      scope.update(content: { hide_grand_total: true })
    end

    it 'returns hidden_grand_totals true' do
      expect(klass.hide_total_args[:hidden_grand_total]).to eq(true)
    end
  end

  context 'with hidden sub totals' do
    before do
      scope.update(content: { hide_sub_totals: true })
    end

    it 'returns hidden sub totals true' do
      expect(klass.hide_total_args[:hidden_sub_total]).to eq(true)
    end
  end

  context 'with hidden converted grand totals' do
    before do
      scope.update(content: { hide_converted_grand_total: true })
    end

    it 'returns hide_converted_grand_total true' do
      expect(klass.hide_total_args[:hide_converted_grand_total]).to eq(true)
    end
  end
end
