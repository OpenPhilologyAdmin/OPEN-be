# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  enumerize :role,
            in:         %i[admin],
            default:    :admin,
            predicates: true,
            scope:      :shallow

  validates :role, :name, presence: true
  validates :password, format: { with: /\A(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}\z/ },
                       unless: -> { password.blank? }
end
