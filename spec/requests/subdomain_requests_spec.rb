# frozen_string_literal: true

require 'rails_helper'

describe 'Subdomain requests', type: :request do

  it 'retrieves the subdomain' do
    get subdomain_path(id: tenant.subdomain)
    expect(response).to have_http_status(:success)
    expect(json[:success]).to be_truthy
    expect(json[:data]).to match({ message: 'Health check pinged successfully.' })
  end
end
