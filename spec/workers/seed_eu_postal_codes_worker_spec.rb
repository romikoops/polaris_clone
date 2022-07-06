# frozen_string_literal: true

require "rails_helper"
RSpec.describe SeedEuPostalCodesWorker, type: :worker do
  let(:mock_s3_data) do
    { "type" => "FeatureCollection",
      "name" => "PCODE_2020_PT_SH",
      "crs" => { "type" => "name", "properties" => { "name" => "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features" =>
       [{ "type" => "Feature",
          "properties" =>
          { "OBJECTID" => 37,
            "POSTCODE" => "1074",
            "CNTR_ID" => "DK",
            "PC_CNTR" => "DK_1074",
            "NUTS3_2021" => "'DK011'",
            "CODE" => "'1074'",
            "GISCO_ID" => "DK_101",
            "NSI_CODE" => "101",
            "LAU_NAT" => "København",
            "LAU_LATIN" => "København",
            "COASTAL" => "YES",
            "CITY_ID" => "DK001C1",
            "GREATER_CI" => nil,
            "FUA_ID" => "DK001L2",
            "DGURBA" => 1 },
          "geometry" => { "type" => "Point", "coordinates" => [12.58363257600007, 55.67956452400006] } }] }.to_json
  end

  let(:desired_trucking_postal_code) do
    Trucking::PostalCode.joins(:country).find_by(postal_code: "1074", countries: { code: "DK" })
  end

  before do
    s3_client_double = instance_double(Aws::S3::Client)
    io_double = instance_double(StringIO, read: mock_s3_data)
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
    allow(s3_client_double).to receive(:get_object).and_return({ body: io_double })
    FactoryBot.create(:legacy_country, code: "DK")
    described_class.new.perform
  end

  describe "#perform" do
    it "Inserts a valid Postalcode from the data", :aggregate_failures do
      expect(desired_trucking_postal_code).to be_present
      expect(desired_trucking_postal_code.point).to eq(RGeo::Geos.factory(srid: 4326).point(12.58363257600007, 55.67956452400006))
    end
  end
end
