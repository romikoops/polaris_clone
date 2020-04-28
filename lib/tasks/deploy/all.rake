# frozen_string_literal: true

namespace :deploy do
  task all: %i[backend] do
  end

  task :backend do
    system 'eb deploy imc-alpha && eb deploy imc-alpha-worker'
  end
end
