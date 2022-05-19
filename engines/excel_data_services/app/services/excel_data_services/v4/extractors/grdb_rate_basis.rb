# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class GrdbRateBasis < ExcelDataServices::V4::Extractors::Base
        GRDB_RATE_BASIS_DATA = [
          { "grdb_rate_basis" => "%", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PERCENTAGE", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_CBM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "F", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_CBM", "base" => 0.02831685, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "C", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 45.359237, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "K", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_KG", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "P", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 0.45359237, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "T", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 907.18474, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "Q", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_UNIT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M3", "cbm_ratio" => 300.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M4", "cbm_ratio" => 400.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M5", "cbm_ratio" => 500.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "W2", "cbm_ratio" => 1000.0, "vm_ratio" => 500.0, "rate_basis" => "PER_CBM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "CA", "cbm_ratio" => 500.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "EA", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_UNIT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "LS", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_SHIPMENT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "PC", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_UNIT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "PD", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_SHIPMENT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "CW", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 45.359237, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "PS", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_SHIPMENT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "FW", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_SHIPMENT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "B/L", "cbm_ratio" => 250.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M25", "cbm_ratio" => 330.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M30", "cbm_ratio" => 333.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M33", "cbm_ratio" => 360.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M36", "cbm_ratio" => 363.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M3A", "cbm_ratio" => 333.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG_FLAT", "base" => 100.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M3R", "cbm_ratio" => 0.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG_FLAT", "base" => 100.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M44", "cbm_ratio" => 444.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M45", "cbm_ratio" => 450.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M7", "cbm_ratio" => 700.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M75", "cbm_ratio" => 750.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M80", "cbm_ratio" => 800.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M9", "cbm_ratio" => 200.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "MIN", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_SHIPMENT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "W1", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 100.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "W2CBM", "cbm_ratio" => 2000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "W3CBM", "cbm_ratio" => 3000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "363KG", "cbm_ratio" => 0.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_KG", "base" => 363.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "PAL", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_UNIT", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "BLK", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_CBM_FLAT", "base" => 4.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "WM", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "WMR", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_WM_FLAT", "base" => 1.0, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M8", "cbm_ratio" => 362.873896, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "M10", "cbm_ratio" => 453.59237, "vm_ratio" => 1000.0, "rate_basis" => "PER_WM", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "W", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_TON", "base" => nil, "grdb_rate_basis_found" => true },
          { "grdb_rate_basis" => "BK3", "cbm_ratio" => 1000.0, "vm_ratio" => 1000.0, "rate_basis" => "PER_X_WM_FLAT", "base" => 3.0, "grdb_rate_basis_found" => true }
        ].freeze

        def frame_data
          GRDB_RATE_BASIS_DATA + existing_rate_basis_data
        end

        def join_arguments
          { "rate_basis" => "grdb_rate_basis" }
        end

        def frame_types
          { "grdb_rate_basis" => :object }
        end

        def existing_rate_basis_data
          @existing_rate_basis_data ||= existing_rate_basis_codes.map do |code|
            { "rate_basis" => code, "grdb_rate_basis" => code, "grdb_rate_basis_found" => true }
          end
        end

        def existing_rate_basis_codes
          @existing_rate_basis_codes ||= Pricings::RateBasis.select(:external_code).distinct.pluck(:external_code)
        end
      end
    end
  end
end
