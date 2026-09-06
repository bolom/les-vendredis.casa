class JournalPostsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_locale

  def index
    @journal_posts = JournalPost.published.where(locale: @locale).recent_first
  end

  def show
    @journal_post = JournalPost.published.find_by!(locale: @locale, slug: params[:slug])
  end

  private

  def set_locale
    @locale = params[:locale] == "fr" ? :fr : :en
  end
end
