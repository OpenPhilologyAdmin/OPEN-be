# frozen_string_literal: true

require 'rails_helper'

describe ProjectSerializer do
  let(:resource) do
    create(:project,
           :with_creator,
           created_at: Time.zone.yesterday.beginning_of_day,
           updated_at: Time.zone.now.beginning_of_day)
  end
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:              resource.id,
        name:            resource.name,
        default_witness: resource.default_witness,
        witnesses:       resource.witnesses,
        status:          resource.status,
        created_by:      resource.created_by,
        creator_id:      resource.creator_id,
        creation_date:   resource.created_at,
        last_edit_by:    resource.last_edit_by,
        last_edit_date:  resource.updated_at,
        witnesses_count: resource.witnesses_count
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
