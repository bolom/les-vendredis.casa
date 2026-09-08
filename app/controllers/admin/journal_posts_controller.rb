module Admin
  class JournalPostsController < BaseController
    before_action :set_post, only: [ :edit, :update ]

    def index
      @journal_posts = JournalPost.recent_first
      @journal_posts = @journal_posts.where(locale: params[:locale]) if params[:locale].in?(%w[en fr])
      if params[:status] == "published"
        @journal_posts = @journal_posts.where(published: true)
      elsif params[:status] == "draft"
        @journal_posts = @journal_posts.where(published: false)
      end
      if params[:q].present?
        needle = "%#{params[:q].strip}%"
        @journal_posts = @journal_posts.where("title ILIKE :needle OR slug ILIKE :needle", needle: needle)
      end
    end

    def new
      @journal_post = JournalPost.new(locale: "fr", published_on: Date.current, published: false)
    end

    def create
      @journal_post = JournalPost.new(post_params)
      if @journal_post.save
        redirect_to edit_admin_journal_post_path(@journal_post.id), notice: "Article enregistré."
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
      params.require(:journal_post).permit(:title, :slug, :locale, :summary, :description, :body_markdown, :published_on, :published, :tag, :image_path, :image_alt)
    end
  end
end
