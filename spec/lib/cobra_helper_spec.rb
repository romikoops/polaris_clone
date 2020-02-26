# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/cobra_helper'

RSpec.describe CobraHelper do
  let(:helper) { described_class.new }

  it '.graphviz' do
    expect(helper.graphviz).to include('app')
  end
end
