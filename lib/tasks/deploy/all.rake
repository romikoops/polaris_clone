# frozen_string_literal: true

namespace :deploy do
  task all: [:client, :backend] do
  end

  task client: :environment do
    klass = Class.new do
      include MultiTenantTools
    end

    Dir.chdir('client') do
      system 'npm run deploy'
    end

    klass.new.update_indexes
  end

  task :backend do
    system 'eb deploy imc-alpha'
    system 'eb deploy imc-alpha-worker'
  end
end
