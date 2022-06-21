# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::ExtractedData, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:extracted_data)).to be_valid
    end
  end
end
