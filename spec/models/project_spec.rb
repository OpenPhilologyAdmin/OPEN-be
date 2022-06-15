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

    it 'creates valid :processing factory' do
      expect(build(:project, :processing)).to be_valid
    end

    it 'creates valid :processed factory' do
      expect(build(:project, :processed)).to be_valid
    end

    it 'creates valid :invalid factory' do
      expect(build(:project, :invalid)).to be_valid
    end
  end
end
