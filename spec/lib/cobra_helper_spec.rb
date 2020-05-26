# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/cobra_helper'

RSpec.describe CobraHelper do
  let(:helper) { described_class.new }
  let(:temp_dir) { Pathname.new("../../tmp").expand_path(__dir__) }

  it '#graphviz' do
    expect(described_class.graphviz(output: temp_dir)).to be_truthy
  end

  it '.graphviz' do
    expect(helper.graphviz).to include('app')
  end
end
