# frozen_string_literal: true

class SignupNotifier
  def initialize(new_user)
    @new_user = new_user
  end

  def perform!
    admins.each do |admin|
      notify_admin(admin)
    end
  end

  private

  def admins
    @admins ||= User.admin.approved
  end

  def notify_admin(admin)
    NotificationMailer.new_signup(@new_user, admin).deliver_later
  end
end
