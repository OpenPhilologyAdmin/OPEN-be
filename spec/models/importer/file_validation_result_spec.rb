# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::FileValidationResult, type: :model do
  describe 'success?' do
    context 'when no errors assigned' do
      it 'is truthy' do
        expect(build(:file_validation_result)).to be_success
      end
    end

    context 'when there are some errors' do
      it 'is falsey' do
        expect(build(:file_validation_result, :unsuccessful)).not_to be_success
      end
    end
  end
end
