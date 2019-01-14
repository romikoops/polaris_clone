# frozen_string_literal: true

module Helpers
  FEATURE_SUBDOMAIN = {
    'QuoteTool' => 'saco'
  }.freeze

  def self.subdomain_for_features(tags:)
    subdomain = tags
                .select { |tag| tag[/@Feature.*/] }
                .map { |tag| FEATURE_SUBDOMAIN[tag.gsub(/@Feature-(.*)/, '\1')] }
                .reject(&:nil?)
                .last

    subdomain || 'demo'
  end

  def print_console_log
    return unless page.driver.browser.manage.respond_to?(:logs)

    logs = page.driver.browser.manage.logs.get(:browser).map { |line| "#{line.level}\t#{line.message}" }

    puts logs.join("\n")
  end

  def take_screenshot(name: @scenario.name)
    path = format(
      '%<feature>s/%<time>s-%<name>s%<status>s',
      feature: @scenario.feature.name.gsub(/[^\w\-]/, '_'),
      name: name.gsub(/[^\w\-]/, '_'),
      status: @scenario.failed? ? '_FAILED' : '',
      time: Time.now.strftime('%H%M%S')
    )

    save_screenshot("#{path}.png") # rubocop:disable Lint/Debugger
    save_page("#{path}.html")

    puts "\n"
    puts "Saved #{path}.png"
    puts "Saved #{path}.html"
  end

  def find_with_retry(*args)
    i = 0
    element = nil
    until element || i > 5
      begin
        element = find(*args)
      rescue Capybara::ElementNotFound
        yield(i)
        i += 1
      end
    end

    element
  end

  def find_with_fallback(*args)
    element = nil

    begin
      element = find(*args)
    rescue Capybara::ElementNotFound
      element = yield
    end

    element
  end
end

World(Helpers)
