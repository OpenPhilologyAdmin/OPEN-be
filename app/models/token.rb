# frozen_string_literal: true

class Token < ApplicationRecord
  validates :index, :variants, presence: true

  belongs_to :project
end
