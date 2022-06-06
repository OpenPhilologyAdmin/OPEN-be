# frozen_string_literal: true

class Project < ApplicationRecord
  validates :name, :witnesses, presence: true

  belongs_to :user
  has_many :tokens, dependent: :destroy
end
