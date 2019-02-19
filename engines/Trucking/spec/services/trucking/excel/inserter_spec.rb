require 'rails_helper'

module Trucking
  module Excel
    RSpec.describe Inserter, type: :service do
      context 'uploading trucking sheets' do
        describe 'location based CBM KG with fees' do
          aws_key = 'data/testing/trucking/trucking_ltl__cbm_kg_with_fees.xlsx'
          aws_path = 'https://assets.itsmycargo.com/data/testing/trucking/trucking_ltl__cbm_kg_with_fees.xlsx'
          tenant = FactoryBot.create(:legacy_tenant)
          hub = FactoryBot.create(:shanghai_hub, tenant: tenant)
         
          before(:all) do
            chinese_locations = [
              { city: 'NANJING'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'SUZHOU'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'NANTONG'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'YANGZHOU'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'YANCHENG'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'XUZHOU'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'LIANYUNGANG'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'CHANGZHOU'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'WUXI'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'CHANGSHU'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'ZHANGJIAGANG'	,county: 'JIANGSU',	country_code: 'CN' },
              { city: 'HEFEI', country:	'ANHUI',	country_code: 'CN' },
              { city: 'BENGBU', country:	'ANHUI',	country_code: 'CN' },
              { city: 'WUHU', country:	'ANHUI',	country_code: 'CN' },
              { city: 'FUYANG', country:	'ANHUI',	country_code: 'CN' },
              { city: 'CHUZHOU', country:	'ANHUI',	country_code: 'CN' },
              { city: 'HUANGSHAN', country:	'ANHUI',	country_code: 'CN' },
              { city: 'XIAN',	county: 'SHAANXI',	country_code: 'CN' },
              { city: 'CHENGDU',	county: 'SICHUAN',	country_code: 'CN' },
              { city: 'CHONGQING',	county: 'CHONGQING',	country_code: 'CN' }
            ]
            result_locations = {}
            chinese_locations.each_with_index do |locations_hash, i|
              result_locations["location_name_#{i}"] = FactoryBot.create!(:locations_name,
                  :reindex,
                  osm_id: i,
                  name: locations_hash[:city],  
                  location: FactoryBot.create(:locations_location, name: locations_hash[:city], osm_id: i),
                  display_name: "#{locations_hash[:city]}, #{locations_hash[:county]}"
                )
              end
            end
            Locations::Name.search_index.delete
            Locations::Name.reindex
            Trucking::Excel::Inserter.new(params: {'xlsx' => aws_path}, hub_id: hub.id).perform
          end
          it 'created the correct number of trucking rates' do
            expect(hub.rates.length).to be(20)
          end

          it 'created the correct number of trucking rates with cbm and kg values' do
            cbm_kg_rates = hub.rates.select {|rate| rate.rates['cbm']}
            expect(cbm_kg_rates).to be(10)
          end

          it 'created the correct number of trucking rates with cbm and kg values' do
            kg_rates = hub.rates.reject {|rate| rate.rates['cbm']}
            expect(kg_rates).to be(10)
          end
        end
      end
    end
  end
end
