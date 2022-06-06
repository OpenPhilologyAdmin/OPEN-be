# frozen_string_literal: true

class Project < ApplicationRecord
  validates :name, :witnesses, presence: true

  has_many :tokens, dependent: :destroy
end
