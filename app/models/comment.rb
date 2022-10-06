# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :token, dependent: :destroy
  belongs_to :user

  validates :body, length: { maximum: 250, allow_blank: false }, presence: true

  default_scope { where(deleted: false).order(created_at: :asc) }

  def created_by
    user.name
  end

  def last_edit_at
    updated_at == created_at ? nil : updated_at
  end
end
