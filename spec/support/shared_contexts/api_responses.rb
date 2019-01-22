# frozen_string_literal: true

shared_examples 'failed create' do
  it 'returns status code 422 (unprocessable entity)' do
    expect(response.status).to eq(422)
  end

  it 'returns the error messages' do
    json = JSON.parse(response.body)['errors']
    expect(json['error']).to eq(message)
  end
end

shared_examples 'a successful show request' do |root|
  it 'returns status code 200 (OK)' do
    expect(response.status).to eq(200)
  end

  it 'returns the specified item' do
    json = JSON.parse(response.body)[root]
    expect(json['id']).to eq(id)
  end
end
