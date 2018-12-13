# frozen_string_literal: true

module ExcelDataServices
  module LocalChargesTool
    UnknownRateBasisReadingError = Class.new(parent::FileParser::Base::ParsingError)
    UnknownRateBasisWritingError = Class.new(parent::FileWriter::Base::WritingError)

    private

    VALID_STATIC_HEADERS = %i(
      hub
      country
      effective_date
      expiration_date
      counterpart_hub
      counterpart_country
      service_level
      carrier
      fee_code
      fee
      mot
      load_type
      direction
      currency
      rate_basis
      minimum
      maximum
      base
      ton
      cbm
      kg
      item
      shipment
      bill
      container
      wm
      range_min
      range_max
      dangerous
    ).freeze

    def specific_charge_params_for_reading(rate_basis, data)
      rate_basis.upcase!
      case rate_basis
      when 'PER_SHIPMENT' then { value: data[:shipment] }
      when 'PER_CONTAINER' then { value: data[:container] }
      when 'PER_BILL' then { value: data[:bill] }
      when 'PER_CBM' then { value: data[:cbm] }
      when 'PER_KG' then { value: data[:kg] }
      when 'PER_TON' then { ton: data[:ton] }
      when 'PER_WM' then { value: data[:wm] }
      when 'PER_ITEM' then { value: data[:item] }
      when 'PER_CBM_TON' then { ton: data[:ton], cbm: data[:cbm] }
      when 'PER_SHIPMENT_CONTAINER' then { shipment: data[:shipment], container: data[:container] }
      when 'PER_BILL_CONTAINER' then { container: data[:container], bill: data[:bill] }
      when 'PER_CBM_KG' then { kg: data[:kg], cbm: data[:cbm] }
      when 'PER_KG_RANGE' then { range_min: data[:range_min], range_max: data[:range_max], kg: data[:kg] }
      when 'PER_X_KG_FLAT' then { value: data[:kg], base: data[:base] }
      else
        raise UnknownRateBasisReadingError, "RATE_BASIS \"#{rate_basis}\" not found!"
      end
    end

    def specific_charge_params_for_writing(rate_basis, data)
      rate_basis.upcase!
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
      when 'PER_X_KG_FLAT' then { kg: data[:value], base: data[:base] }
      else
        raise UnknownRateBasisError, "RATE_BASIS \"#{rate_basis}\" not found!"
      end
    end
  end
end
