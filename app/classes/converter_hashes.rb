# frozen_string_literal: true

module ConverterHashes
  humanized_mot_and_load_type = {
    ocean: {
      container: 'Ocean FCL',
      cargo_item: 'Ocean LCL'
    },
    rail: {
      container: 'Rail FCL',
      cargo_item: 'Rail LCL'
    },
    air: {
      container: '',
      cargo_item: 'Air'
    }
  }
end
