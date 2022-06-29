# frozen_string_literal: true

class Token < ApplicationRecord
  validates :index, :variants, presence: true
  attribute :variants, TokenVariant.to_array_type
  attribute :grouped_variants, TokenGroupedVariant.to_array_type

  belongs_to :project
end
