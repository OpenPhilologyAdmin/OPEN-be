# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Extractors::Base, type: :service do
  let(:project) { create(:project, :with_source_file) }
  let(:service) { described_class.new(project:) }

  describe '#initialize' do
    it 'sets the project' do
      expect(service.instance_variable_get('@project')).to eq(project)
    end

    it 'opens the data file' do
      expect(service.source_file).to eq(project.source_file)
    end

    it 'sets the default_witness' do
      expect(service.default_witness).to eq(project.default_witness)
    end

    it 'initializes tokens array' do
      expect(service.instance_variable_get('@tokens')).to eq([])
    end
  end

  describe '#process' do
    it 'raises NotImplementedError by default' do
      expect { service.process }.to raise_error(NotImplementedError)
    end
  end
end
