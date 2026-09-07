module Admin
  class JournalPostsController < ApplicationController
    before_action :set_post, only: [ :edit, :update ]

    def index
      @journal_posts = JournalPost.recent_first
    end

    def new
      @journal_post = JournalPost.new(locale: "fr", published_on: Date.current, published: false)
    end

    def create
      @journal_post = JournalPost.new(post_params)
      if @journal_post.save
        redirect_to edit_admin_journal_post_path(@journal_post.id), notice: "Article créé."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @journal_post.update(post_params)
        redirect_to edit_admin_journal_post_path(@journal_post.id), notice: "Article enregistré."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_post
      @journal_post = JournalPost.find(params[:id])
    end

    def post_params
      params.require(:journal_post).permit(:title, :slug, :locale, :summary, :body_markdown, :published_on, :published, :tag, :image_path, :image_alt)
    end
  end
end
