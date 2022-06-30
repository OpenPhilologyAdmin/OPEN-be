# frozen_string_literal: true

class Project < ApplicationRecord
  DEFAULT_WITNESS_REQUIRED_FOR_TYPE = 'text/plain'
  include ActiveStorageSupport::SupportForBase64
  extend Enumerize
  attr_accessor :default_witness_name

  enumerize :status,
            in:         %i[processing processed invalid],
            default:    :processing,
            predicates: true,
            scope:      :shallow

  validates :name, presence: true, length: { maximum: 50 }
  validates :default_witness, presence: true, if: :default_witness_required?
  validates :default_witness_name, length: { maximum: 50, allow_blank: true }

  has_many :tokens, dependent: :destroy
  has_many :project_roles, dependent: :destroy

  has_one_base64_attached :source_file

  def source_file_content_type
    return unless source_file.attached?

    source_file.blob.content_type
  end

  def invalidate!
    update(status: :invalid, import_errors:)
  end

  def default_witness_required?
    source_file_content_type == DEFAULT_WITNESS_REQUIRED_FOR_TYPE
  end
end
