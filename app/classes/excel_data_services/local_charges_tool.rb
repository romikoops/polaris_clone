# frozen_string_literal: true

module ExcelDataServices
  module LocalChargesTool
    def specific_charge_params_for_reading(rate_basis, single_data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      rate_basis = RateBasis.get_internal_key(rate_basis.upcase)

      case rate_basis
      when 'PER_SHIPMENT'
        { value: single_data[:shipment] }
      when 'PER_CONTAINER'
        { value: single_data[:container] }
      when 'PER_BILL'
        { value: single_data[:bill] }
      when 'PER_CBM'
        { value: single_data[:cbm] }
      when 'PER_KG'
        { value: single_data[:kg] }
      when 'PER_TON'
        { ton: single_data[:ton] }
      when 'PER_WM'
        { value: single_data[:wm] }
      when 'PER_ITEM'
        { value: single_data[:item] }
      when 'PER_CBM_TON'
        { ton: single_data[:ton], cbm: single_data[:cbm] }
      when 'PER_SHIPMENT_CONTAINER'
        { shipment: single_data[:shipment], container: single_data[:container] }
      when 'PER_BILL_CONTAINER'
        { container: single_data[:container], bill: single_data[:bill] }
      when 'PER_CBM_KG'
        { kg: single_data[:kg], cbm: single_data[:cbm] }
      when 'PER_KG_RANGE'
        { kg: single_data[:kg] }
      when 'PER_WM_RANGE'
        { wm: single_data[:wm] }
      when 'PER_X_KG_FLAT'
        { value: single_data[:kg], base: single_data[:base] }
      when 'PER_UNIT_TON_CBM_RANGE'
        if single_data[:cbm] && single_data[:ton]
          raise StandardError, "There should only be one value for rate_basis 'PER_UNIT_TON_CBM_RANGE'."
        end

        if single_data[:cbm]
          { cbm: single_data[:cbm] }
        elsif single_data[:ton]
          { ton: single_data[:ton] }
        end
      end
    end
  end
end
