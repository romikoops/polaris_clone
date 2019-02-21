# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelperHelper. For example:
#
# describe ApplicationHelperHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ApplicationHelper do
  describe '.asset_data_base64' do
    it 'successfully' do
      expect(Digest::SHA256.hexdigest(helper.asset_data_base64('application.css'))).to eq '20d8d9b76e12dbf52bd3039371cb07ba8cfebffd1bf927b70a35619831c99a89'
    end
  end

  describe '.format_to_price' do
    it 'with hash' do
      expect(helper.format_to_price('value' => 1.231234, 'currency' => 'EUR')).to eq '1.23 EUR'
    end

    it 'with args' do
      expect(helper.format_to_price(1.231234, 'EUR')).to eq '1.23 EUR'
    end

    it 'with number' do
      expect(helper.format_to_price(1.231234)).to eq '1.23'
    end
  end

  describe '.valid_price_hash?' do
    it 'with correct args' do
      expect(helper.valid_price_hash?(['value' => 1.231234, 'currency' => 'EUR'])).to be_truthy
      expect(helper.valid_price_hash?(['val' => 1.231234, 'currency' => 'EUR'])).to be_truthy
    end

    it 'with invalid args' do
      expect(helper.valid_price_hash?(['amount' => 1.231234, 'symbol' => 'EUR'])).to be_falsey
    end
  end

  describe '.trunc' do
    it 'with short text' do
      expect(helper.trunc('shorttext')).to eq 'shorttext'
    end

    it 'with long text' do
      expect(helper.trunc('Brown fox jumped over the fence' * 20)).to eq 'Brown fox jumped over the fenceBrown fox jumpe...'
    end
  end

  describe '.line_wrap' do
    it 'with short text' do
      expect(helper.line_wrap('shorttext')).to eq "shorttext\n"
    end

    it 'with long text' do
      expect(helper.line_wrap('Brown fox jumped over the fence' * 20)).to eq "Brown fox jumped over the fenceBrown fox\njumped over the fenceBrown fox jumped\nover the fenceBrown fox jumped over th..."
    end
  end

  describe '.formatted_datetime' do
    it 'correctly' do
      Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
        expect(helper.formatted_datetime(Time.current)).to eq '22 Feb 2019 | 11:54 AM'
      end
    end
  end

  describe '.formatted_date' do
    it 'correctly' do
      Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
        expect(helper.formatted_date(Time.current)).to eq '22 Feb 2019'
      end
    end
  end
end
