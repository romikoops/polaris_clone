class SeedingInterface
  def initialize(args = {})
    @actions         = args[:actions]         || args["actions"]         || {}
    @welcome_message = args[:welcome_message] || args["welcome_message"] || ""
    add_exit_action
  end

  def init
    log_welcome_message

    loop do
      log_list_of_actions
      log_choose_your_action_text
      
      ask_user_for_options
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
    @actions.each do |action_name, action|
      puts
      action.call if @options.include?(action_name) || run_all?
    end
  end

  def ask_user_for_options
    @options = STDIN.gets.chomp.gsub(/\D/, "").chars.map { |n| @actions.keys[n.to_i - 1] }
  end

  def log_welcome_message
    size = @welcome_message.size
    puts "=" * 50
    print " " * ((50 - size) / 2)
    puts @welcome_message
    puts "=" * 50
  end

  def log_list_of_actions
    @actions.keys.each_with_index do |action_name, i|
      puts "#{i + 1} - #{action_name.to_s.humanize.capitalize}"
    end
  end

  def log_choose_your_action_text
    puts
    puts "Choose your Actions (ex: '124' will execute no. 1, 2 & 4)"
    puts
    puts "[ Press Enter to execute all ]"
    puts
    print " > "
  end

  def log_separator
    puts " "
    puts "=" * 50
    puts " "
  end
end