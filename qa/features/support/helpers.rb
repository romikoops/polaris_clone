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
    logs = page.driver.browser.manage.logs.get(:browser).map { |line| [line.level, line.message] }

    puts logs.join("\n")
  end

  def take_screenshot(name: @scenario.name)
    path = format(
      '%<feature>s/%<time>s-%<name>s',
      feature: @scenario.feature.name.gsub(/[^\w\-]/, '_'),
      name: name.gsub(/[^\w\-]/, '_'),
      time: Time.now.strftime('%H%M%S')
    )

    save_screenshot("#{path}.png") # rubocop:disable Lint/Debugger
    save_page("#{path}.html")

    puts "Saved #{path}.png"
    puts "Saved #{path}.html"
  end
end

World(Helpers)
