# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#validations' do
    subject(:comment) { described_class.new }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:token) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:body).is_at_most(250) }
    it { is_expected.not_to allow_value(' ').for(:body) }
  end

  describe '.default_scope' do
    let!(:comment_one) { create(:comment, body: 'Nice comment.', created_at: DateTime.new(2022, 2, 1)) }
    let!(:comment_two) { create(:comment, body: 'Even better one!', created_at: DateTime.new(2022, 1, 1)) }

    it 'orders by ascending created_at' do
      expect(described_class.all).to eq([comment_two, comment_one])
    end
  end

  describe '#factories' do
    it 'creates valid default factory' do
      expect(build(:comment)).to be_valid
    end
  end

  describe '.created_by' do
    let(:user) { build(:user, :admin, :approved) }
    let(:comment) { build(:comment, user:) }

    it { expect(comment.created_by).to eq(user.name) }
  end

  describe '.last_edit_at' do
    let(:date1) { DateTime.new(2022, 9, 12) }
    let(:date2) { DateTime.new(2022, 9, 11) }

    context 'when created_at is the same as updated_at' do
      let(:comment) { build(:comment, created_at: date1, updated_at: date1) }

      it 'returns nil' do
        expect(comment.last_edit_at).to be_nil
      end
    end

    context 'when created_at differs from updated_at' do
      let(:comment) { build(:comment, created_at: date2, updated_at: date1) }

      it 'returns nil' do
        expect(comment.last_edit_at).to eq(date1)
      end
    end
  end
end
