# frozen_string_literal: true

shared_context 'with_tenant', :with_tenant do
  let(:tenant) { create(:tenant) }
end
