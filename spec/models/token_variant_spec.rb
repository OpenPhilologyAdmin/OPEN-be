# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenVariant, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_variant)).to be_valid
    end
  end
end
