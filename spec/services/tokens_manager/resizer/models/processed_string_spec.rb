# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Models::ProcessedString, type: :model do
  let(:string) { Faker::Lorem.word }
  let(:record) { described_class.new(string:, substring_before:, substring_after:) }

  context 'when there is a substring_before' do
    let(:substring_before) { Faker::Lorem.word }
    let(:substring_after) { nil }

    it 'applies the substring_before before the given string' do
      expect(record.string).to eq("#{substring_before}#{string}")
    end
  end

  context 'when there is a substring_after' do
    let(:substring_before) { nil }
    let(:substring_after) { Faker::Lorem.word }

    it 'applies the substring_after after the given string' do
      expect(record.string).to eq("#{string}#{substring_after}")
    end
  end

  context 'when there are no substrings' do
    let(:substring_before) { nil }
    let(:substring_after) { nil }

    it 'equals the given string' do
      expect(record.string).to eq(string)
    end
  end

  context 'when there are both substrings' do
    let(:substring_before) { Faker::Lorem.word }
    let(:substring_after) { Faker::Lorem.word }

    it 'applies the substring_before and the substring_after to the given string' do
      expect(record.string).to eq("#{substring_before}#{string}#{substring_after}")
    end
  end

  context 'when there are placeholders' do
    let(:substring_before) { Faker::Lorem.word }
    let(:substring_after) { Faker::Lorem.word }
    let(:string) { Faker::Lorem.word }
    let(:placeholder) { FormattableT::EMPTY_VALUE_PLACEHOLDER }

    let(:record) do
      described_class.new(
        string:           "#{string}#{placeholder}",
        substring_before: "#{substring_before}#{placeholder}",
        substring_after:  "#{placeholder}#{substring_after}"
      )
    end

    it 'removes all placeholders' do
      expect(record.string).to eq("#{substring_before}#{string}#{substring_after}")
    end
  end
end
