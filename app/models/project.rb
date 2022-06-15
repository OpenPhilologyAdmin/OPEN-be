# frozen_string_literal: true

class Project < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  extend Enumerize

  enumerize :status,
            in:         %i[processing processed invalid],
            default:    :processing,
            predicates: true,
            scope:      :shallow

  validates :name, presence: true

  has_many :tokens, dependent: :destroy
  has_many :project_roles, dependent: :destroy

  has_one_base64_attached :source_file
end
