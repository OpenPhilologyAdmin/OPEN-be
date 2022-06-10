# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::ExtractedData, type: :model do
  describe '#assign_project_id_to_tokens' do
    let(:record) { build(:extracted_data) }
    let(:project) { create(:project) }

    it 'adds project_id at the end of raw token array' do
      record.assign_project_id_to_tokens(project.id)
      record.tokens.each do |token|
        expect(token.last).to eq(project.id)
      end
    end
  end
end
