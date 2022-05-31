# frozen_string_literal: true

# A temporary fix until Devise/Warden team introduces their solution for RoR 7
# Without this the application would raise ActionDispatch::Request::Session::DisabledSessionError

module RackSessionFix
  extend ActiveSupport::Concern

  class FakeRackSession < Hash
    def enabled?
      false
    end
  end

  included do
    before_action :set_fake_rack_session_for_devise

    private

    def set_fake_rack_session_for_devise
      request.env['rack.session'] ||= FakeRackSession.new
    end
  end
end
