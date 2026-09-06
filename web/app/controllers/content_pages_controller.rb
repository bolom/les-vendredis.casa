class ContentPagesController < ApplicationController
  allow_unauthenticated_access

  def show
    @content_page = ContentPage.published.find_by!(path: params[:path])
    @locale = @content_page.locale.to_sym
  end
end
