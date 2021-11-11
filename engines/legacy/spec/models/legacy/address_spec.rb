# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe Address, type: :model do
    let(:lat_lng) { {latitude: 57.7072326, longitude: 11.9670171} }
    let(:address) { FactoryBot.create(:legacy_address, :gothenburg) }
    let(:address_with_lat_lng) { FactoryBot.create(:legacy_address, **lat_lng) }

    before do
      Geocoder::Lookup::Test.reset
      Geocoder.configure(lookup: :test)
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
      Geocoder::Lookup::Test.add_stub("Landvetter, Sweden", [
        "coordinates" => [57.7072326, 11.9670171]
      ])
      Geocoder::Lookup::Test.add_stub({country: "sweden"}, ["coordinates" => [57.7072326, 11.9670171]])
      Geocoder::Lookup::Test.add_stub(", Gothenburg", ["coordinates" => [57.7072326, 11.9670171]])
      Geocoder::Lookup::Test.add_stub("Gothenburg, Sweden", ["coordinates" => [57.7072326, 11.9670171]])
    end

    describe "#full_address" do
      before do
        Geocoder::Lookup::Test.add_stub([56.0, 12.1], [
          "country_code" => nil,
          "postal_code" => "11222",
          "city" => "Gothenburg",
          "address_components" => ["short_name" => "Helsingborg"]])
      end

      let(:address) { FactoryBot.create(:legacy_address, :gothenburg, street: "A wonderful street", street_number: "10") }
      let(:address_with_no_country) { FactoryBot.create(:legacy_address, latitude: 56.0, longitude: 12.1, country_id: nil) }

      it "returns the full address with street, street_number, postcode, city and country" do
        expect(address.full_address).to eq "A wonderful street 10, 43813, Gothenburg, Sweden"
      end

      it "does not contain the country name in the full address, when the address has no country attached" do
        expect(address_with_no_country.full_address).to eq "11222, Gothenburg"
      end
    end

    describe ".get_zip_code" do
      it "returns the zipcode" do
        expect(address.get_zip_code).to eq("43813")
      end
    end

    describe ".new_from_raw_params" do
      let(:address_attributes) { FactoryBot.attributes_for(:legacy_address) }

      it "returns the zipcode" do
        address_attributes["country"] = address_attributes[:country].name
        address_attributes.delete(:country)
        address = described_class.new_from_raw_params(address_attributes)

        expect(address.save).to be_truthy
      end
    end

    describe ".reverse_geocoded_by" do
      it "gets address from coordinates" do
        address_with_lat_lng.reverse_geocode
        expect(address_with_lat_lng.zip_code).to eq("43813")
      end
    end

    describe "#get_zip_code" do
      let(:address_without_zipcode) { FactoryBot.create(:legacy_address, zip_code: nil, **lat_lng) }

      it "returns the zip code from the address" do
        expect(address_without_zipcode.get_zip_code).to eq("43813")
      end

      it "returns the zip code from the address with zipcode" do
        expect(address_with_lat_lng.get_zip_code).to eq("43813")
      end
    end

    describe ".geocoded_address" do
      let(:address) { described_class.geocoded_address "Landvetter, Sweden" }

      it "find the address from the user input" do
        expect(address.geocoded_address).to eq "Göteborg, Sweden"
      end
    end

    describe ".lat_lng_string" do
      it "converts coordinates to string" do
        expect(
          address_with_lat_lng.lat_lng_string
        ).to eq("#{address_with_lat_lng.latitude},#{address_with_lat_lng.longitude}")
      end
    end

    describe "#furthest_hubs" do
      let(:hubs) { [FactoryBot.create(:legacy_hub)] }

      it "furthest_hubs" do
        expect(address_with_lat_lng.furthest_hubs(hubs)).to eq(hubs)
      end
    end

    describe "#to_custom_hash" do
      let(:keys) {
        %i[city country geocoded_address id longitude name street street_number zip_code latitude location_type]
      }

      it "produces a hash from address" do
        expect(address.to_custom_hash.keys).to match_array(keys)
      end
    end

    describe "#set_geocoded_address_from_fields!" do
      it "it completes the address based on it`s fields" do
        address.set_geocoded_address_from_fields!

        expect(address.geocoded_address).to eq(", 43813 Gothenburg, Sweden")
      end
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
