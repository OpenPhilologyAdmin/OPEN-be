# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  alias_attribute :registration_date, :created_at

  enumerize :role,
            in:         %i[admin],
            default:    :admin,
            predicates: true,
            scope:      :shallow

  validates :role, :name, presence: true
  validates :password, format: { with: /\A(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d_\-.@$!%*?&]{8,}\z/ },
                       unless: -> { password.blank? }

  scope :approved, -> { where.not(approved_at: nil) }
  scope :most_recent_first, -> { order('created_at desc') }

  has_many :project_roles, dependent: :destroy
  has_many :comments, dependent: :destroy

  def account_approved?
    approved_at.present?
  end

  alias account_approved account_approved?

  def approved_admin?
    admin? && account_approved?
  end

  def approve!
    return false if account_approved?

    update(approved_at: Time.zone.now)
    true
  end

  def active_for_authentication?
    super && account_approved?
  end

  def inactive_message
    return :unconfirmed unless confirmed?
    return :not_approved unless account_approved?

    super
  end
end
