# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enumerize :role,
            in:         %i[admin],
            default:    :admin,
            predicates: true,
            scope:      :shallow

  validates :role, :name, presence: true
  validates :password, format: { with: /\A(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}\z/ },
                       unless: -> { password.blank? }

  scope :approved, -> { where.not(approved_at: nil) }

  def account_approved
    approved_at.present?
  end
end
