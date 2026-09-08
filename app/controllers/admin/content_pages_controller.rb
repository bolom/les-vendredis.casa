module Admin
  class ContentPagesController < BaseController
    before_action :require_technical_access

    def index
      @content_pages = ContentPage.order(:path, :locale)
      @content_pages = @content_pages.where(locale: params[:locale]) if params[:locale].in?(%w[en fr])
      if params[:q].present?
        needle = "%#{params[:q].strip}%"
        @content_pages = @content_pages.where("path ILIKE :needle OR title ILIKE :needle", needle: needle)
      end
    end

    def show
      @content_page = ContentPage.find(params[:id])
    end

    def new
      @content_page = ContentPage.new(locale: "fr", published: true)
    end

    def create
      @content_page = ContentPage.new(content_page_params)
      if @content_page.save
        redirect_to admin_content_page_path(@content_page.id), notice: "Page enregistrée."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @content_page = ContentPage.find(params[:id])
    end

    def update
      @content_page = ContentPage.find(params[:id])
      if @content_page.update(content_page_params)
        redirect_to admin_content_page_path(@content_page.id), notice: "Page enregistrée."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      content_page = ContentPage.find(params[:id])
      content_page.destroy!
      redirect_to admin_content_pages_path, notice: "Page « #{content_page.title} » supprimée."
    end

    private

    def content_page_params
      params.require(:content_page).permit(
        :path, :locale, :title, :description, :canonical_url, :robots,
        :alternate_en_url, :alternate_fr_url, :structured_data, :body_html, :published
      )
    end
  end
end
