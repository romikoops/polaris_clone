# frozen_string_literal: true

module Helpers
  FEATURE_SUBDOMAIN = {
    'QuoteTool' => 'demo-agent'
  }.freeze

  def self.app_host(subdomain: 'demo')
    host = ENV.fetch('TARGET_URL', 'itsmycargo.com')

    if host[/localhost/]
      "http://#{host}"
    else
      "https://#{subdomain}.#{host}"
    end
  end

  def self.subdomain_for_features(tags:)
    tags
      .select { |tag| tag[/@Feature.*/] }
      .map { |tag| FEATURE_SUBDOMAIN[tag.gsub(/@Feature(.*)/, '\1')] }
      .reject(&:nil?)
      .last
  end

  def print_console_log
    page.driver.browser.manage.logs.get(:browser).each do |log|
      puts log.to_s
    end
  end

  def take_screenshot(name: nil)
    name ||= [@scenario.name, @step_index].join('_')

    name.gsub!(/[^\w\-]/, '_')

    screenshot_path = format('./report/%<time>s-%<name>s.png', time: Time.now.strftime('%Y%m%d%H%M%S'), name: name)
    save_screenshot(screenshot_path) # rubocop:disable Lint/Debugger
    puts "Saved screenshot: #{screenshot_path}"
  end
end

World(Helpers)
