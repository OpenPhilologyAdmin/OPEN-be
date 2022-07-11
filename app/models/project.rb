# frozen_string_literal: true

class Project < ApplicationRecord
  DEFAULT_WITNESS_REQUIRED_FOR_TYPE = 'text/plain'
  include ActiveStorageSupport::SupportForBase64
  extend Enumerize
  attr_accessor :default_witness_name

  attribute :witnesses, Witness.to_array_type
  alias_attribute :creation_date, :created_at
  alias_attribute :last_edit_date, :updated_at

  enumerize :status,
            in:         %i[processing processed invalid],
            default:    :processing,
            predicates: true,
            scope:      :shallow

  validates :name, presence: true, length: { maximum: 50 }
  validates :default_witness, presence: true, if: :default_witness_required?
  validates :default_witness_name, length: { maximum: 50, allow_blank: true }
  validates :witnesses, store_model: { merge_array_errors: true }

  has_many :tokens, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  has_many :owners, -> { merge(ProjectRole.owner) },
           through: :project_roles,
           source:  :user

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

  def witnesses_count
    witnesses.size
  end

  def creator
    owners.first
  end

  def created_by
    creator&.name
  end

  def find_witness!(siglum)
    selected_witness = witnesses.find { |witness| witness.siglum == siglum }
    selected_witness.presence || raise(ActiveRecord::RecordNotFound)
  end
end
