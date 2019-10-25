require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json, :xml

  skip_before_action :verify_authenticity_token
end
