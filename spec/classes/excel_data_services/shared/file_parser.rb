# frozen_string_literal: true

RSpec.shared_examples 'parse excel sheet successfully' do
  let(:options) { { tenant: tenant, file_or_path: file_or_path } }

  it 'returns successfully' do
    expect(described_class.parse(options)).to eq(correctly_parsed_data)
  end
end
