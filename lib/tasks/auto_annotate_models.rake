# frozen_string_literal: true

if Rails.env.development? && !ENV['SKIP_ANNOTATE']
  require 'annotate'
  namespace :annotate do
    desc 'Annotate models'
    task :models do
      sh('bundle exec annotate -p after --model-dir app/models')
      Dir['engines/*/app/models'].each do |engine|
        sh("bundle exec annotate -p after --model-dir #{engine}")
      end
    end
  end

  Rake::Task['db:migrate'].enhance do
    Rake::Task['annotate:models'].invoke
  end
end
