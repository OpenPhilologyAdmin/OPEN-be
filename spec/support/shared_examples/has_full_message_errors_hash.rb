# frozen_string_literal: true

RSpec.shared_examples 'resource with full message errors hash' do
  describe '#errors_hash' do
    it 'returns the hash of errors full messages' do
      resource.valid?
      expect(resource.errors_hash).to eq(resource.errors.to_hash(true))
    end
  end
end
