# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::ExtractedData, type: :model do
  describe '#assign_project_to_tokens' do
    let(:record) { build(:extracted_data) }
    let(:project) { create(:project) }

    it 'adds project_id at the end of raw token array' do
      record.assign_project_to_tokens(project)
      record.tokens.each do |token|
        expect(token.project).to eq(project)
      end
    end
  end
end
