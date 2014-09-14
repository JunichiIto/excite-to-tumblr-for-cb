class BlogImagesController < ApplicationController
  before_action :set_blog_image, only: [:show, :edit, :update, :destroy]

  def index
    @blog_images = BlogImage.order(:excite_url).reverse_order.page params[:page]
  end

  def show
  end

  def new
    @blog_image = BlogImage.new
  end

  def edit
  end

  def create
    @blog_image = BlogImage.new(blog_image_params)

    respond_to do |format|
      if @blog_image.save
        format.html { redirect_to @blog_image, notice: 'Blog image was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @blog_image.update(blog_image_params)
        format.html { redirect_to @blog_image, notice: 'Blog image was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @blog_image.destroy
    respond_to do |format|
      format.html { redirect_to blog_images_url, notice: 'Blog image was successfully destroyed.' }
    end
  end

  private
    def set_blog_image
      @blog_image = BlogImage.find(params[:id])
    end

    def blog_image_params
      params.require(:blog_image).permit(:excite_url, :tumblr_id, :tumblr_info)
    end
end
