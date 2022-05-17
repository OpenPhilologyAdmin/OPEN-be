# frozen_string_literal: true

class ApplicationController < ActionController::API
  Pundit::Authorization
end
