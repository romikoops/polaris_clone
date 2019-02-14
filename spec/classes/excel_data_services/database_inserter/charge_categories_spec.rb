# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserter::ChargeCategories do
  describe '.perform' do
    let(:data) do
      [{ internal_code: nil, fee_code: 'AMS', fee_name: 'Automated Manifest System', row_nr: 2 },
       { internal_code: nil, fee_code: 'BAF', fee_name: 'Bunker Adjustment Factor', row_nr: 3 },
       { internal_code: nil, fee_code: 'BAS', fee_name: 'Basic Ocean Freight', row_nr: 4 },
       { internal_code: nil, fee_code: 'CARGO', fee_name: 'Ocean Freight', row_nr: 5 },
       { internal_code: nil, fee_code: 'EBAF_PSS', fee_name: 'EBAF PSS', row_nr: 6 },
       { internal_code: nil, fee_code: 'EBS', fee_name: 'Emergency Bunker Surcharge', row_nr: 7 },
       { internal_code: nil, fee_code: 'EFS/EBS', fee_name: 'EFS/EBS', row_nr: 8 },
       { internal_code: nil, fee_code: 'EXPORT', fee_name: 'Origin Local Charges', row_nr: 9 },
       { internal_code: nil, fee_code: 'ISPS', fee_name: 'Ship and Port Facility Security ', row_nr: 10 },
       { internal_code: nil, fee_code: 'OCEAN_FREIGHT', fee_name: 'Ocean Freight', row_nr: 11 },
       { internal_code: nil, fee_code: 'OFT', fee_name: 'OFT', row_nr: 12 },
       { internal_code: nil, fee_code: 'OTHER_CHARGES', fee_name: 'Other Charges', row_nr: 13 },
       { internal_code: nil, fee_code: 'THC', fee_name: 'Container Service Charges', row_nr: 14 },
       { internal_code: nil, fee_code: 'IMPORT', fee_name: 'Destination Local Charges', row_nr: 15 }]
    end
    let(:tenant) { create(:tenant) }
    let(:klass_identifier) { 'ChargeCategories' }

    it 'creates the correct number of charge categories' do
      stats = described_class.insert(tenant: tenant, klass_identifier: klass_identifier, data: data, options: {})
      expect(stats.dig(:charge_categories, :number_updated)).to be(14)
      expect(ChargeCategory.where(tenant_id: tenant.id).count).to be(14)
      expect(ChargeCategory.find_by(tenant_id: tenant.id, code: 'export').name).to eq('Origin Local Charges')
    end

    it 'finds and replaces all other Charge Categories for that tenant' do
      charges = []
      (1..10).to_a.each do |i|
        charges << create(:charge,
                          charge_category: create(:charge_category,
                                                  code: 'ams',
                                                  name: "#{i}_test",
                                                  tenant_id: tenant.id),
                          children_charge_category: create(:charge_category,
                                                           code: 'thc',
                                                           name: "#{i}_test",
                                                           tenant_id: tenant.id))
      end

      stats = described_class.insert(tenant: tenant, klass_identifier: klass_identifier, data: data, options: {})
      new_ams_charge = ChargeCategory.find_by(code: 'ams', tenant_id: tenant.id)
      new_thc_charge = ChargeCategory.find_by(code: 'thc', tenant_id: tenant.id)
      charge_ids = charges.map(&:id)
      expect(stats.dig(:charge_categories, :number_updated)).to be(14)
      expect(ChargeCategory.where(code: 'ams', tenant_id: tenant.id).count).to eq(1)
      expect(ChargeCategory.where(code: 'thc', tenant_id: tenant.id).count).to eq(1)
      expect(Charge.where(id: charge_ids).pluck(:charge_category_id).uniq).to eq([new_ams_charge.id])
      expect(Charge.where(id: charge_ids).pluck(:children_charge_category_id).uniq).to eq([new_thc_charge.id])
    end
  end
end
