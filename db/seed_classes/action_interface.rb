# frozen_string_literal: true

require "#{Rails.root}/db/seed_helpers/interface_helpers.rb"

class ActionInterface
  include InterfaceHelpers

  def initialize(args = {})
    @actions         = args[:actions]         || args['actions'] || {}
    @welcome_message = args[:welcome_message] || args['welcome_message']
    add_exit_action
  end

  def init
    system 'clear'
    log_welcome_message

    loop do
      log_list_of_actions
      log_choose_your_action_text

      @options = ask_user_for_options(@actions.keys)
      run_chosen_actions

      break if should_exit?

      log_separator
    end
  end

  private

  def add_exit_action
    @actions.merge!(exit: -> { exit })
  end

  def exit
    puts nil, 'Exiting...'
  end

  def should_exit?
    @options.include?(:exit)
  end

  def run_chosen_actions
    system 'clear'
    @actions.each do |action_name, action|
      next unless @options.include?(action_name)

      puts
      action.call
      puts
    end
  end

  def log_welcome_message
    log_in_title_format(@welcome_message)
  end

  def log_list_of_actions
    log_numbered_list(@actions.keys) { |action_name| action_log_format(action_name) }
  end

  def action_log_format(action_name)
    action_name.to_s.gsub('__', ' [+]').underscore.humanize
  end

  def log_choose_your_action_text
    log_prompt_text("Choose your Actions (ex: '1,2,4' will execute no. 1, 2 & 4)")
  end
end
