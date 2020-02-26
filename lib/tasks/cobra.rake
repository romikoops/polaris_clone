# frozen_string_literal: true

require_relative '../cobra_helper'

namespace :cobra do
  desc 'Update CBRA Documentation'
  task docs: :environment do
    Tempfile.open(%w[cobra .dot]) do |io|
      io.puts CobraHelper.new.graphviz
      io.close

      sh "dot -Tpdf -odoc/cobra/graph.pdf #{io.path}"
    end
  end
end
