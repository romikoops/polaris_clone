# frozen_string_literal: true

require "spec_helper"

require_relative "../../lib/cobra_helper"

RSpec.describe CobraHelper do
  let(:helper) { described_class.new }

  context "class methods" do
    let(:temp_dir) {
      Pathname.new(File.expand_path("../../tmp", __dir__))
    }

    it "#uml" do
      described_class.uml(output: temp_dir)
      expect(temp_dir.join("graph.puml")).to exist
    end
  end

  it ".uml" do
    expect(helper.uml).to include("@startuml")
  end
end
