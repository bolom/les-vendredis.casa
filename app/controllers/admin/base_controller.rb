# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    # The back-office is French-only, whatever the public-site locale params.
    around_action ->(_controller, action) { I18n.with_locale(:fr) { action.call } }

    helper_method :admin_nav_class, :technical_access?

    private

    # Honest authorization boundary: until a separate access level exists, the
    # technical zone (payments, users, diagnostics) is gated by an explicit
    # flag on the admin user, granted from the Users screen or the console.
    # House screens stay available to every admin account.
    def require_technical_access
      return if technical_access?

      redirect_to admin_root_path, alert: "Section technique réservée aux comptes autorisés."
    end

    def technical_access?
      Current.user&.technical_access
    end

    def admin_nav_class(path)
      "is-active" if request.path == path
    end
  end
end
