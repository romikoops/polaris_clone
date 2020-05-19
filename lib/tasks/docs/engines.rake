# frozen_string_literal: true

require_relative "../../cobra_helper"

namespace :docs do
  desc "Update Engines Documentation"
  task engines: :environment do
    Tempfile.open(%w[engines .dot]) do |io|
      io.puts CobraHelper.new.graphviz
      io.close

      sh "dot -Tpdf -odoc/engines/graph.pdf #{io.path}"
    end
  end
end
