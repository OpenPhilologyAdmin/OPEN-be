# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::FileValidators::Base, type: :service do
  let(:project) { create(:project, :with_source_file) }
  let(:service) { described_class.new(project:) }

  describe '#initialize' do
    it 'sets the project' do
      expect(service.instance_variable_get('@project')).to eq(project)
    end

    it 'opens the data file' do
      expect(service.source_file).to eq(project.source_file)
    end
  end

  describe '#validate' do
    it 'raises NotImplementedError by default' do
      expect { service.validate }.to raise_error(NotImplementedError)
    end
  end
end
