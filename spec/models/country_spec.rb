# frozen_string_literal: true

require 'rails_helper'

# Allow outbound HTTP requests.
WebMock.allow_net_connect!

describe Country, type: :model do
	context 'class methods' do
		context '.geo_find_by_name' do
			it 'returns nil if no country was found' do      		
		  	expect(described_class.geo_find_by_name("asdfas")).to be_nil
			end

			it 'returns the correct country' do
				country = create(:country)
		  	expect(described_class.geo_find_by_name("sweden")).to eq(country)
			end
		end
	end
end
