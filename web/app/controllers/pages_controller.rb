class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @locale = params[:locale] == "fr" ? :fr : :en
  end
end
