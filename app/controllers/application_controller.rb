class ApplicationController < ActionController::Base
  protected

  include Concerns::Security
  include Concerns::Flash
end
