# frozen_string_literal: true

require "#{Rails.root}/db/seed_helpers/interface_helpers.rb"

class ChooseOptionInterface
  include InterfaceHelpers

  attr_reader :chosen_options

  def initialize(args = {})
    @options     = args[:options]     || args['options']     || []
    @prompt_text = args[:prompt_text] || args['prompt_text'] || ''
  end

  def run
    log_numbered_list(@options)
    log_prompt_text(@prompt_text)
    @chosen_options = ask_user_for_options(@options)
    log_separator
  end
end
