# frozen_string_literal: true

module InterfaceHelpers
  def log_numbered_list(options)
    options.each_with_index do |option, i|
      alignment_buffer = ' ' * (3 - (i + 1).to_s.size)
      formatted_option = block_given? ? yield(option) : option_log_format(option)

      puts " #{i + 1}#{alignment_buffer}-  #{formatted_option}"
    end
  end

  def ask_user_for_options(options)
    raw_user_input       = STDIN.gets.chomp
    sanitized_user_input = raw_user_input.gsub(/[^(\d|,)]/, '')
    option_indexes       = sanitized_user_input.split(',')

    option_indexes.map { |n| options[n.to_i - 1] }
  end

  def log_prompt_text(prompt_text)
    puts nil, prompt_text, nil
    print ' > '
  end

  def log_in_title_format(text)
    return if text.nil?

    size = text.size
    puts '=' * 50
    print ' ' * ((50 - size) / 2)
    puts text
    puts '=' * 50
  end

  def log_separator
    puts '=' * 50, nil
  end

  private

  def option_log_format(option)
    option.to_s.underscore.humanize
  end
end
