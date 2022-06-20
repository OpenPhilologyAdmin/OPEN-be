# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '#validations' do
    subject(:project) { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:project)).to be_valid
    end

    it 'creates valid :status_processing factory' do
      expect(build(:project, :status_processing)).to be_valid
    end

    it 'creates valid :status_processed factory' do
      expect(build(:project, :status_processed)).to be_valid
    end

    it 'creates valid :status_invalid factory' do
      expect(build(:project, :status_invalid)).to be_valid
    end

    it 'creates valid :with_source_file factory' do
      expect(build(:project, :with_source_file)).to be_valid
    end
  end
end
