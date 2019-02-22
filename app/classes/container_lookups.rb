# frozen_string_literal: true

class ContainerLookups
  def self.get_descriptions
    xlsx = Roo::Spreadsheet.open("#{Rails.root}/db/static_data/container_descriptions.xlsx")
    table = {}
    rows = xlsx.parse(size_class: 'SIZE_CLASS', description: 'DESCRIPTION')
    rows.each do |row|
      table.merge!(row[:size_class] => row[:description])
    end
    table
  end

  def self.get_weights
    xlsx = Roo::Spreadsheet.open("#{Rails.root}/db/static_data/container_tare_weights.xlsx")
    table = {}
    rows = xlsx.parse(size_class: 'SIZE_CLASS', weight: 'TARE_WEIGHT_IN_KG')
    rows.each do |row|
      table.merge!(row[:size_class] => row[:weight])
    end
    table
  end

  def self.get_pricing_weight_steps
    xlsx = Roo::Spreadsheet.open("#{Rails.root}/db/static_data/pricing_weight_steps.xlsx")
    steps = []
    rows = xlsx.parse(pricing_weight_steps: 'PRICING_WEIGHT_STEPS')
    rows.each do |row|
      steps << row[:pricing_weight_steps]
    end
    steps.sort!.reverse
  end
end
