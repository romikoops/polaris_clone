# frozen_string_literal: true

require "rails_helper"

RSpec.describe Address do
  let(:address) { FactoryBot.create(:address) }

  before do
    Geocoder::Lookup::Test.add_stub([57.7072326, 11.9670171], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Göteborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43813"
    ])
    Geocoder::Lookup::Test.add_stub({country: "Sweden"}, [
      "address_components" => ["short_name" => "Sweden"],
      "country" => "Sweden", "code" => "SE"
    ])
    Geocoder::Lookup::Test.add_stub(", 43813 Gothenburg, Sweden", [
      "coordinates" => [57.7072326, 11.9670171],
      "address" => "Göteborg, Sweden",
      "state" => "Götaland",
      "country" => "Sweden",
      "country_code" => "SE"
    ])
    Geocoder::Lookup::Test.add_stub(", Gothenburg", ["coordinates" => [57.7072326, 11.9670171]])
    Geocoder::Lookup::Test.add_stub("Gothenburg, Sweden", ["coordinates" => [57.7072326, 11.9670171]])
  end

  describe ".create_and_geocode" do
    it "successfully" do
      address = described_class.create_and_geocode("city" => "Gothenburg", "country" => "Sweden")

      expect(address.city).to eq "Gothenburg"
    end
  end

  describe ".self.geocoded_address" do
    it "successfully" do
      address = described_class.geocoded_address("Gothenburg, Sweden")

      expect(address.city).to eq "Gothenburg"
      expect(address.latitude).to eq 57.7072326
    end
  end

  describe ".new_from_raw_params" do
    it "successfully" do
      expect(described_class.new_from_raw_params("city" => "Gothenburg", "country" => "Sweden").city).to eq "Gothenburg"
    end
  end

  describe ".create_from_raw_params!" do
    it "successfully" do
      address = described_class.create_from_raw_params!("city" => "Gothenburg", "country" => "Sweden")
      expect(address).to be_valid
      expect(address.city).to eq "Gothenburg"
    end
  end

  describe "#reverse_geocoded_by" do
    let(:address) { FactoryBot.create(:address, latitude: 57.7072326, longitude: 11.9670171) }

    it "successfully" do
      address.reverse_geocode
      expect(address.zip_code).to eq "43813"
      expect(address.city).to eq "Gothenburg"
      expect(address.country&.name).to eq "Sweden"
    end
  end

  describe "#set_geocoded_address_from_fields!" do
    it "successfully" do
      address.set_geocoded_address_from_fields!

      expect(address.geocoded_address).to eq ", 43813 Gothenburg, Sweden"
    end
  end

  describe "#geocode_from_address_fields!" do
    it "successfully" do
      address.geocode_from_address_fields!

      expect(address.geocoded_address).to eq ", 43813 Gothenburg, Sweden"
      expect(address.latitude).to eq 57.7072326
      expect(address.longitude).to eq 11.9670171
    end
  end

  describe ".primary_for?" do
    let(:user) { FactoryBot.create(:users_client) }
    let(:addresses) { FactoryBot.create_list(:address, 2) }

    before do
      addresses.each do |address|
        FactoryBot.create(:user_addresses, user: user, address: address)
      end
    end

    it "successfully" do
      expect(addresses.first).to be_primary_for(user)
      expect(addresses.last).not_to be_primary_for(user)
    end
  end

  describe ".city_country" do
    it "successfully" do
      expect(address.city_country).to eq "Gothenburg, Sweden"
    end
  end

  describe ".full_address" do
    it "successfully" do
      expect(address.full_address).to eq "43813, Gothenburg, Sweden"
    end
  end

  describe ".lat_lng_string" do
    it "successfully" do
      expect(address.lat_lng_string).to eq "57.694253,11.854048"
    end
  end

  describe ".to_custom_hash" do
    it "successfully" do
      expect(address.to_custom_hash).to eq(
        address_type: nil,
        city: "Gothenburg",
        country: "Sweden",
        geocoded_address: "438 80 Landvetter, Sweden",
        id: address.id,
        latitude: 57.694253,
        longitude: 11.854048,
        name: "Gothenburg",
        street: nil,
        street_number: nil,
        zip_code: "43813"
      )
    end
  end

  describe ".get_zip_code" do
    it "successfully" do
      expect(address.get_zip_code).to eq "43813"
    end

    it "sanitized" do
      address = FactoryBot.create(:address, zip_code: "43 81-3")

      expect(address.get_zip_code).to eq "43813"
    end
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  city             :string
#  geocoded_address :string
#  latitude         :float
#  location_type    :string
#  longitude        :float
#  name             :string
#  photo            :string
#  premise          :string
#  province         :string
#  street           :string
#  street_address   :string
#  street_number    :string
#  zip_code         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  country_id       :integer
#  sandbox_id       :uuid
#
# Indexes
#
#  index_addresses_on_sandbox_id  (sandbox_id)
#
