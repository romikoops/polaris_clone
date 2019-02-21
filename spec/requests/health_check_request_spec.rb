# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'health check request', type: :request do
  it 'retrieves a health check on root path' do
    get '/'
    expect(response).to be_successful
    expect(json[:success]).to be_truthy
    expect(json[:data]).to match(message: 'Health check pinged successfully.')
  end

  it 'retrieves a health check on health check path' do
    get health_check_path
    expect(response).to be_successful
    expect(json[:success]).to be_truthy
    expect(json[:data]).to match(message: 'Health check pinged successfully.')
  end
end
