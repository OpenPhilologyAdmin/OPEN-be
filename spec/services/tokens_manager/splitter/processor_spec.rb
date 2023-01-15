# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Splitter::Processor, type: :service do
  let(:project) do
    create(:project, witnesses: [build(:witness, siglum: 'A'),
                                 build(:witness, siglum: 'B'),
                                 build(:witness, siglum: 'C'),
                                 build(:witness, siglum: 'D')])
  end

  let(:source_token) do
    create(:token, project:, index: 0, variants: [build(:token_variant,
                                                        witness: 'A',
                                                        t:       'This is a nice text'),
                                                  build(:token_variant,
                                                        witness: 'B',
                                                        t:       'This is quite a bad text')])
  end

  let(:other_token) do
    create(:token, project:, index: 1, variants: [build(:token_variant,
                                                        witness: 'C',
                                                        t:       'This is a nice text'),

                                                  build(:token_variant,
                                                        witness: 'D',
                                                        t:       'This is quite a bad text')])
  end

  let(:new_variants) do
    [
      {
        witness: 'A',
        t:       'This is{scissors} a nice text'
      },
      {
        witness: 'B',
        t:       'This is quite a b{scissors}ad text'
      }
    ]
  end

  before do
    allow(TokensManager::Resizer::Processors::FollowingTokensMover).to receive(:perform).and_call_original
    described_class.new(project:, source_token:, new_variants:).perform
    project.reload
  end

  describe '#perform' do
    it 'saves new tokens' do
      expect(project.tokens.count).to eq(2)
    end

    it 'assigns correct indexes to the new tokens' do
      expect(project.tokens.pluck(:index)).to eq([0, 1])
    end

    it 'generates group variants' do
      project.tokens.each do |token|
        expect(token.grouped_variants).not_to be_empty
      end
    end

    it 'deletes source token' do
      expect(source_token.reload.deleted).to be(true)
    end
  end
end
