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

  def is_number? # rubocop:disable Naming/PredicateName
    true if Float(self)
  rescue StandardError
    false
  end

  # Color logging
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end
