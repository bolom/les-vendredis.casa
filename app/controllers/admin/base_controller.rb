# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    # The back-office is French-only, whatever the public-site locale params.
    around_action ->(_controller, action) { I18n.with_locale(:fr) { action.call } }

    private

    def admin_nav_class(path)
      "is-active" if request.path == path
    end
  end
end
