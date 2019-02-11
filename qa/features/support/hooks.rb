# frozen_string_literal: true

Before do |scenario|
  @suite_passed ||= true
  @scenario = scenario
  @step_index = 0

  # Connect to correct subdomain
  tags = scenario.tags.map(&:name)
  subdomain = Helpers.subdomain_for_features(tags: tags)

  if %w(1 true).include?(ENV['SINGLE_TENANT'])
    # TODO: Implement dynamic skip scenario if features not available for tenant
    # skip_this_scenario
  else
    # Select correct tenant
    visit '/'
    find('.ccb_change_tenant').click
    find('p', text: subdomain).click
    expect(find('.ccb_change_tenant')).to have_content(/(#{subdomain})/i)
  end
end

Around do |_scenario, block|
  begin # rubocop:disable Style/RedundantBegin
    block.call
  rescue StandardError
    cbt_score('fail')
    raise
  end
end

AfterStep do
  @step_index += 1
end

After do |scenario|
  @suite_passed &= scenario.failed?

  cbt_score(@suite_passed ? 'fail' : 'pass')

  if scenario.failed?
    print_console_log
    take_screenshot
  end
end
