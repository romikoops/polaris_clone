# frozen_string_literal: true

require 'rails_helper'

describe 'Tenant requests', type: :request do

  it 'retrieves a health check' do
    get subdomain_tenants_path(subdomain_id: tenant.subdomain, name: tenant.subdomain)
    expect(response).to have_http_status(:success)
    expect(json[:success]).to be_truthy
    expect(json[:data]).to match({ message: 'Health check pinged successfully.' })
  end
end
