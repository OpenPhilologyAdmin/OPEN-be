# frozen_string_literal: true

require 'rails_helper'

describe UserSerializer do
  let(:record) { create(:user) }
  let(:serializer) { described_class.new(record:) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:                     record.id,
        email:                  record.email,
        name:                   record.name,
        role:                   record.role,
        account_approved:       record.account_approved?,
        registration_date:      record.registration_date,
        last_edited_project_id: record.last_edited_project_id
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
