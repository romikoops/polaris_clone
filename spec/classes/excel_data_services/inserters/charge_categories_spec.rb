# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::ChargeCategories do
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

    context 'when no charge categories exist' do
      it 'creates the correct number of charge categories' do
        stats = described_class.insert(tenant: tenant, data: data, options: {})
        aggregate_failures do
          expect(stats.dig('legacy/charge_categories'.to_sym, :number_created)).to be(14)
          expect(Legacy::ChargeCategory.where(tenant_id: tenant.id).count).to be(14)
          expect(Legacy::ChargeCategory.find_by(tenant_id: tenant.id, code: 'export').name).to eq('Origin Local Charges')
        end
      end
    end

    context 'when updating existing charge categories and charges' do
      let!(:existing_charges) do
        [
          create(
            :charge,
            charge_category: create(:charge_category,
                                    code: 'ams',
                                    name: 'test',
                                    tenant_id: tenant.id),
            children_charge_category: create(:charge_category,
                                             code: 'thc',
                                             name: 'test',
                                             tenant_id: tenant.id)
          )
        ]
      end
      let(:new_ams_charge) { Legacy::ChargeCategory.find_by(code: 'ams', tenant_id: tenant.id) }
      let(:new_thc_charge) { Legacy::ChargeCategory.find_by(code: 'thc', tenant_id: tenant.id) }
      let(:charge_ids) { existing_charges.map(&:id) }
      let(:charges) { Legacy::Charge.where(id: charge_ids) }

      it 'finds and replaces all other Charge Categories for that tenant' do
        stats = described_class.insert(tenant: tenant, data: data, options: {})
        aggregate_failures do
          expect(stats.dig('legacy/charge_categories'.to_sym, :number_created)).to be(12)
          expect(Legacy::ChargeCategory.where(code: 'ams', tenant_id: tenant.id).count).to eq(1)
          expect(Legacy::ChargeCategory.where(code: 'thc', tenant_id: tenant.id).count).to eq(1)
          expect(charges.pluck(:charge_category_id).uniq).to eq([new_ams_charge.id])
          expect(charges.pluck(:children_charge_category_id).uniq).to eq([new_thc_charge.id])
        end
      end
    end
  end
end
