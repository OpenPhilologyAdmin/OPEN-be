# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenEditorialRemark, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_editorial_remark)).to be_valid
    end
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:type).in_array(described_class::EDITORIAL_REMARK_TYPES.values) }
  end
end
