# frozen_string_literal: true

require "spec_helper"

require_relative "../../lib/cobra_helper"

RSpec.describe CobraHelper do
  let(:helper) { described_class.new }

  context "class methods" do
    let(:temp_dir) { Pathname.new(Dir.mktmpdir) }

    after do
      FileUtils.remove_entry temp_dir
    end

    it "#graphviz" do
      expect(described_class.graphviz(output: temp_dir)).to be_truthy
    end
  end

  it ".graphviz" do
    expect(helper.graphviz).to include("app")
  end
end
