class ValueFromCell
  def initialize(cell:)
    @cell = cell
  end

  def perform
    cell_value = cell.value
    return cell_value unless cell_value.is_a?(Numeric) || (cell_value.is_a?(String) && cell_value.match(/\d/))

    currency_descr = extract_currency(cell)
    extracted_value = extract_value(cell_value)

    return cell_value unless currency_descr && Money::Currency.table[currency_descr.downcase.to_sym].present?

    parse_to_money(currency_descr, extracted_value)
  end

  private

  attr_reader :cell

  def extract_currency(cell)
    captures = if (cell_format = cell.format)
      cell_format.scan(/\[\$([^+\-\d]+)\]/).flatten
    elsif cell.value
      cell.value.strip.scan(/^-?(?:\d+(?:\.\d*)?|\.\d+)[[:space:]][A-Z]{3}$|^[A-Z]{3}[[:space:]]-?(?:\d+(?:\.\d*)?|\.\d+)$/)
    end

    return if captures.empty?

    captures.first[/[A-Z]{3}/]
  end

  def parse_to_money(currency_descr, cell_value)
    Monetize.parse("#{currency_descr} #{cell_value.to_f}", "no-fallback-currency", assume_from_symbol: true)
  end

  def extract_value(cell_value)
    cell_value.is_a?(Numeric) ? cell_value : cell_value[/-?(?:\d+(?:\.\d*)?|\.\d+)/]
  end
end
