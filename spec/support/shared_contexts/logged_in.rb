# frozen_string_literal: true

shared_context 'logged_in', :logged_in do
  let(:user) { create(:user, tenant: tenant) }
  sign_in(:user)
end
