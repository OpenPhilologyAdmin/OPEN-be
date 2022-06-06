# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Importer::Base, type: :service do
  let(:data_path) { 'spec/fixtures/sample_project.txt' }
  let(:service) { described_class.new(data_path:) }

  describe '#initialize' do
    it 'sets the data_path' do
      expect(service.instance_variable_get('@data_path')).to eq(Rails.root.join(data_path))
    end

    it 'initializes errors hash' do
      expect(service.instance_variable_get('@errors')).to eq({})
    end
  end
end
