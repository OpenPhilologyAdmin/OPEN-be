# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectRole, type: :model do
  describe '#validations' do
    subject(:project_role) { described_class.new }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:project_role)).to be_valid
    end

    it 'creates valid owner factory' do
      expect(build(:project_role, :owner)).to be_valid
    end
  end
end
