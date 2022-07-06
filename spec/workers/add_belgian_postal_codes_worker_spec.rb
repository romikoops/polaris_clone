# frozen_string_literal: true

require "rails_helper"
RSpec.describe AddBelgianPostalCodesWorker, type: :worker do
  let(:mock_belgian_s3_data) do
    { "type" => "FeatureCollection",
      "name" => "belgium_postal_district_boundaries",
      "crs" => { "type" => "name", "properties" => { "name" => "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features" =>
       [{ "type" => "Feature",
          "properties" => { "gid" => 1, "join_count" => 1, "nouveau_po" => "5012", "frequency" => 2, "cp_speciau" => 1, "shape_leng" => 977.714222741, "shape_area" => 38_380.3395682 },
          "geometry" =>
       { "type" => "MultiPolygon",
         "coordinates" =>
         [[[[4.870718307836368, 50.46205879723374, 0.0],
           [4.87145394904913, 50.46184190700711, 0.0],
           [4.871383936269186, 50.46184010260628, 0.0],
           [4.871335372804102, 50.461838851778225, 0.0],
           [4.871315148286008, 50.461838113953945, 0.0],
           [4.871295215068909, 50.46183695501069, 0.0],
           [4.871275595792102, 50.46183538474023, 0.0],
           [4.871256304625692, 50.46183341117275, 0.0],
           [4.871237361401979, 50.461831045011365, 0.0],
           [4.871218783126675, 50.461828296072085, 0.0],
           [4.871200583988982, 50.46182517418324, 0.0],
           [4.871182779586139, 50.46182168916713, 0.0],
           [4.871165386943046, 50.4618178526379, 0.0],
           [4.871148420258226, 50.461813675322844, 0.0],
           [4.871131890903735, 50.46180916706256, 0.0],
           [4.871115815923535, 50.46180434126922, 0.0],
           [4.871100203872919, 50.46179920779552, 0.0],
           [4.871085068978777, 50.46179378006584, 0.0],
           [4.87107042261322, 50.461788067920715, 0.0],
           [4.871056274777978, 50.46178208480277, 0.0],
           [4.871042636873613, 50.46177584324964, 0.0],
           [4.871036007546914, 50.46177161222784, 0.0],
           [4.871013622408546, 50.46175732515756, 0.0],
           [4.870991664653324, 50.46174070680289, 0.0],
           [4.870968670069832, 50.46172074757085, 0.0],
           [4.870951352057745, 50.46170402823455, 0.0],
           [4.870942933847411, 50.461688362763006, 0.0],
           [4.87092480721686, 50.46165463244342, 0.0],
           [4.8709142094042, 50.461634910899164, 0.0],
           [4.870875686999106, 50.46124852561774, 0.0],
           [4.87087116779996, 50.461192006744646, 0.0],
           [4.869973020513097, 50.46077834368513, 0.0],
           [4.869587122796016, 50.460597654358544, 0.0],
           [4.869494367163152, 50.4606559726978, 0.0],
           [4.869397692988271, 50.46070615528725, 0.0],
           [4.869289272556034, 50.46075460919624, 0.0],
           [4.869202535335646, 50.46078864236432, 0.0],
           [4.869117797886708, 50.46081321246882, 0.0],
           [4.869128600039113, 50.46071113123223, 0.0],
           [4.868965753068601, 50.46076652257805, 0.0],
           [4.868816089706869, 50.46081537300814, 0.0],
           [4.868799724573296, 50.46081942264351, 0.0],
           [4.867672263648568, 50.460584218804456, 0.0],
           [4.867305654911465, 50.460770082324004, 0.0],
           [4.867269943467252, 50.460828655693135, 0.0],
           [4.866587241462168, 50.46072512476812, 0.0],
           [4.867171846111608, 50.46115535353174, 0.0],
           [4.866439281419988, 50.46174428046527, 0.0],
           [4.867172610051156, 50.46185478117013, 0.0],
           [4.867770968709515, 50.46193790308798, 0.0],
           [4.868429929283763, 50.461986625339385, 0.0],
           [4.86912461785601, 50.46200098301379, 0.0],
           [4.869743902136659, 50.46198117521596, 0.0],
           [4.870216502693102, 50.46195033859113, 0.0],
           [4.870718307836368, 50.46205879723374, 0.0]]]] } }] }.to_json
  end
  let(:mock_postal_s3_data) do
    { "type" => "FeatureCollection",
      "name" => "PCODE_2020_PT_SH",
      "crs" => { "type" => "name", "properties" => { "name" => "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features" =>
       [{ "type" => "Feature",
          "properties" =>
         { "OBJECTID" => 107_385,
           "POSTCODE" => target_post_code,
           "CNTR_ID" => "BE",
           "PC_CNTR" => "BE_9681",
           "NUTS3_2021" => "'BE235'",
           "CODE" => "'9681'",
           "GISCO_ID" => "BE_45064",
           "NSI_CODE" => "45064",
           "LAU_NAT" => "Maarkedal",
           "LAU_LATIN" => "Maarkedal",
           "COASTAL" => "NO",
           "CITY_ID" => nil,
           "GREATER_CI" => nil,
           "FUA_ID" => nil,
           "DGURBA" => 3 },
          "geometry" => { "type" => "Point", "coordinates" => [postal_point.x, postal_point.y] } }] }.to_json
  end
  let(:postal_point) { RGeo::Geos.factory(srid: 4326).point(3.5949, 50.7956) }
  let(:target_post_code) { "9681" }
  let(:geocoded_postal_code) { nil }
  let(:location_name_postal_code) { nil }
  let(:location_country_code) { "de" }

  before do
    s3_client_double = instance_double(Aws::S3::Client)
    io_belgian_double = instance_double(StringIO, read: mock_belgian_s3_data)
    io_postal_double = instance_double(StringIO, read: mock_postal_s3_data)
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
    allow(s3_client_double).to receive(:get_object).with(
      bucket: AddBelgianPostalCodesWorker::BUCKET, key: AddBelgianPostalCodesWorker::PATH
    ).and_return({ body: io_belgian_double })
    allow(s3_client_double).to receive(:get_object).with(
      bucket: AddBelgianPostalCodesWorker::BUCKET, key: AddBelgianPostalCodesWorker::POINT_PATH
    ).and_return({ body: io_postal_double })
    FactoryBot.create(:legacy_country, code: "BE")
    Geocoder::Lookup::Test.add_stub([50.46137744410162, 4.868851532461883], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Hamburg Hamburg DE",
      "city" => "Hamburg",
      "country" => "Germany",
      "country_code" => "DE",
      "postal_code" => geocoded_postal_code,
      "geometry" => {
        "location" => {
          "lat" => 50.46137744410162,
          "lng" => 4.868851532461883
        }
      }
    ])
    FactoryBot.create(:locations_name,
      :reindex,
      name: location_name_postal_code,
      postal_code: location_name_postal_code,
      country_code: "BE",
      point: RGeo::Geos.factory(srid: 4326).point(4.868851532461883, 50.46137744410162))
    Locations::Name.reindex
    FactoryBot.create(:locations_location, name: target_post_code, country_code: location_country_code, admin_level: nil)
    described_class.new.perform
  end

  describe "#perform" do
    context "when the postal code is found from the eu list" do
      let(:postal_point) { RGeo::Geos.factory(srid: 4326).point(4.868851532461883, 50.46137744410162) }

      it "creates a Locations::Location with the correct name" do
        expect(Locations::Location.where(country_code: "be", admin_level: nil).pluck(:name)).to eq([target_post_code])
      end
    end

    context "when the postal code is found via Locations::Name" do
      let(:location_name_postal_code) { target_post_code }

      it "creates a Locations::Location with the correct name" do
        expect(Locations::Location.where(country_code: "be", admin_level: nil).pluck(:name)).to eq([location_name_postal_code])
      end
    end

    context "when the postal code is found via reverse geocoding" do
      let(:geocoded_postal_code) { target_post_code }

      it "creates a Locations::Location with the correct name" do
        expect(Locations::Location.where(country_code: "be", admin_level: nil).pluck(:name)).to eq([target_post_code])
      end
    end

    context "when the postal code Locations::Location already exists" do
      let(:postal_point) { RGeo::Geos.factory(srid: 4326).point(4.868851532461883, 50.46137744410162) }
      let(:location_country_code) { "be" }

      it "updates the existing Locations::Location" do
        expect(Locations::Location.count).to eq(1)
      end
    end

    context "when the postal code is not found" do
      it "ignores the rows it cannot name" do
        expect(Locations::Location.where(country_code: "be", admin_level: nil).pluck(:name)).to eq([])
      end
    end
  end
end
