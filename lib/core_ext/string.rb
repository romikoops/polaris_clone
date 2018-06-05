# frozen_string_literal: true

class String
  def remove_extra_spaces!
    gsub!(/\s+/, ' ').gsub!(/\s+,/, ',').strip!
                     .gsub!(/^,/, '').gsub!(/,\z/, '').strip!
                     .gsub!(/,+/, ',')
  end

  def remove_extra_spaces
    gsub(/\s+/, ' ').gsub(/\s+,/, ',').strip
                    .gsub(/^,/, '').gsub(/,\z/, '').strip
                    .gsub(/,+/, ',')
  end

  def is_number?
    true if Float(self)
  rescue StandardError
    false
  end
end
