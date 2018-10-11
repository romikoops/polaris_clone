# frozen_string_literal: true

require 'rest-client'

module CrossBrowserTesting
  def cbt_enabled?
    ENV['CROSSBROWSER_USERNAME'] && ENV['CROSSBROWSER_AUTHKEY']
  end

  def cbt_request(method, url, params)
    return unless cbt_enabled?
    
    username = ENV.fetch('CROSSBROWSER_USERNAME', '').sub('@', '%40')
    authkey = ENV.fetch('CROSSBROWSER_AUTHKEY', '')
    base_url = "https://#{username}:#{authkey}@crossbrowsertesting.com/api/v3"

    RestClient.send(method, base_url + url, params)
  end

  def cbt_screenshot(description: '')
    return unless cbt_enabled?

    session_id = page.driver.browser.session_id

    response = cbt_request(:post, "/selenium/#{session_id}/snapshots",
                           "selenium_test_id=#{session_id}")
    snapshot_hash = /(?<="hash": ")((\w|\d)*)/.match(response)[0]

    cbt_request(:put, "/selenium/#{session_id}/snapshots/#{snapshot_hash}",
                "description=#{description}")
  end

  def cbt_score(score)
    return unless cbt_enabled?

    raise 'Invalid Score' unless %w(pass fail unset).include?(score)

    cbt_request(:put, "/selenium/#{page.driver.browser.session_id}", "action=set_score&score=#{score}")
  end
end

World(CrossBrowserTesting)
