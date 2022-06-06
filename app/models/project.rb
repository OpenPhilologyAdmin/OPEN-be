# frozen_string_literal: true

class Project < ApplicationRecord
  validates :name, :witnesses, presence: true

  has_many :tokens, dependent: :destroy
  has_many :project_roles, dependent: :destroy
end
