# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Inserter, type: :service do
  let(:project) { create(:project, :status_processing) }
  let(:extracted_data) { build(:extracted_data, project:) }
  let(:service) { described_class.new(project:, extracted_data:) }

  describe '#process' do
    before do
      service.process
      project.reload
    end

    it 'passes correct witnesses to project' do
      project.witnesses.each_with_index do |witness, index|
        expect(witness.attributes).to eq(extracted_data.witnesses[index].attributes)
      end
    end

    it 'updates project status to :processed' do
      expect(project.status).to eq(:processed)
    end

    it 'saves first of witnesses as default_witness' do
      expect(project.default_witness).to eq(extracted_data.witnesses.first.siglum)
    end

    it 'creates correct number of tokens' do
      expect(project.tokens.size).to eq(extracted_data.tokens.size)
    end

    it 'creates correct tokens' do
      extracted_data.tokens.each do |raw_token|
        matching_saved_token = project.tokens.find_by(index: raw_token.index)

        expect(matching_saved_token.variants).to eq(raw_token.variants)
        expect(matching_saved_token.grouped_variants).to eq(raw_token.grouped_variants)
      end
    end
  end
end
