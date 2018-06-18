class SeedingInterface
  def initialize(args = {})
    @actions         = args[:actions]         || args["actions"]         || {}
    @welcome_message = args[:welcome_message] || args["welcome_message"]
    add_exit_action
  end

  def init
    system "clear"
    log_welcome_message

    loop do
      log_list_of_actions
      log_choose_your_action_text
      
      @options = ask_user_for_options
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
    puts
    puts "Exiting..."
  end

  def should_exit?
    @options.include?(:exit) || run_all?
  end

  def run_all?
    @options.empty?
  end

  def run_chosen_actions
    system "clear"
    @actions.each do |action_name, action|
      next unless @options.include?(action_name) || run_all?
      puts
      action.call
      puts
    end
  end

  def ask_user_for_options
    raw_user_input       = STDIN.gets.chomp
    sanitized_user_input = raw_user_input.gsub(/[^(\d|,)]/, "")
    option_indexes       = sanitized_user_input.split(",")

    option_indexes.map { |n| @actions.keys[n.to_i - 1] }
  end

  def log_welcome_message
    return if @welcome_message.nil?

    size = @welcome_message.size
    puts "=" * 50
    print " " * ((50 - size) / 2)
    puts @welcome_message
    puts "=" * 50
  end

  def log_list_of_actions
    @actions.keys.each_with_index do |action_name, i|
      alignment_buffer = " " * (3 - (i + 1).to_s.size)
      
      puts "#{i + 1}#{alignment_buffer}-  #{action_log_format(action_name)}"
    end
  end

  def action_log_format(action_name)
    action_name.to_s.gsub("__", " [+]").humanize.capitalize
  end

  def log_choose_your_action_text
    puts
    puts "Choose your Actions (ex: '1,2,4' will execute no. 1, 2 & 4)"
    puts
    puts "[ Press Enter to execute all ]"
    puts
    print " > "
  end

  def log_separator
    puts "=" * 50
    puts " "
  end
end