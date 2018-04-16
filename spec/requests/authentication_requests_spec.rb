require 'rails_helper'

describe 'Authentication by token', type: :request do

  let(:user) { create(:user, tenant: tenant) }
  sign_in(:user)

  it 'signs user in' do

    get subdomain_user_path(subdomain_id: tenant.subdomain, id: user.id)
    expect(controller.current_user).to eq(user)

    get authenticated_root_path
    expect(controller.current_user).to be_nil
  end

end
