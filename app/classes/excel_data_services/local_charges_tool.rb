# frozen_string_literal: true

module ExcelDataServices
  module LocalChargesTool
    UnknownRateBasisWritingError = Class.new(parent::FileWriter::Base::WritingError)

    private

    def specific_charge_params_for_writing(rate_basis, data)
      rate_basis = RateBasis.get_internal_key(rate_basis.upcase)
      case rate_basis
      when 'PER_SHIPMENT' then { shipment: data[:value] }
      when 'PER_CONTAINER' then { container: data[:value] }
      when 'PER_BILL' then { bill: data[:value] }
      when 'PER_CBM' then { cbm: data[:value] }
      when 'PER_KG' then { kg: data[:value] }
      when 'PER_TON' then { ton: data[:ton] }
      when 'PER_WM' then { wm: data[:value] }
      when 'PER_ITEM' then { item: data[:value] }
      when 'PER_CBM_TON' then { ton: data[:ton], cbm: data[:cbm] }
      when 'PER_SHIPMENT_CONTAINER' then { shipment: data[:shipment], container: data[:container] }
      when 'PER_BILL_CONTAINER' then { container: data[:container], bill: data[:bill] }
      when 'PER_CBM_KG' then { kg: data[:kg], cbm: data[:cbm] }
      when 'PER_KG_RANGE' then { range_min: data[:range_min], range_max: data[:range_max], kg: data[:kg] }
      when 'PER_WM_RANGE' then { range_min: data[:range_min], range_max: data[:range_max], kg: data[:wm] }
      when 'PER_X_KG_FLAT' then { kg: data[:value], base: data[:base] }
      when 'PER_UNIT_TON_CBM_RANGE'
        { cbm: data[:cbm],
          ton: data[:ton],
          range_min: data[:range_min],
          range_max: data[:range_max] }
      else
        raise UnknownRateBasisWritingError, "RATE_BASIS \"#{rate_basis}\" not found!"
      end
    end
  end
end
