# frozen_string_literal: true

include ExcelTools
puts '# Overwrite ports from excel sheet'
ports = File.open("#{Rails.root}/db/dummydata/ports_master.xlsx")
req = { 'xlsx' => ports }
ExcelTool::PortsUploader.new(params: req).perform
