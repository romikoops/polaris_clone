# frozen_string_literal: true

namespace :deploy do
  task all: %i[backend] do
  end

  task :backend do
    require 'aws-sdk-elasticbeanstalk'

    client = Aws::ElasticBeanstalk::Client.new

    # Find current application version
    app_dir = File.expand_path("../../../", __dir__)
    git = Git.open(app_dir)
    current_head = git.object('HEAD').sha

    response = client.describe_application_versions({
      application_name: "imcr-staging",
      version_labels: [current_head]
    })
    if response.application_versions.count.zero?
      puts "--- Cannot find Application Version for #{current_head}"
      puts ""
      puts "* Please wait for master Jenkins build to finish"
      puts "* Or HOTFIX: run `eb deploy imc-alpha && eb deploy imc-alpha-worker`"
      puts ""
      fail
    end

    application_version = response.application_versions.first.version_label

    system("eb deploy imc-alpha --version #{application_version}") || fail
    system("eb deploy imc-alpha-worker --version #{application_version}") || fail
  end
end
