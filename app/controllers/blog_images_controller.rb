class BlogImagesController < ApplicationController
  before_action :set_blog_image, only: [:show, :edit, :update, :destroy]

  # GET /blog_images
  # GET /blog_images.json
  def index
    @blog_images = BlogImage.all
  end

  # GET /blog_images/1
  # GET /blog_images/1.json
  def show
  end

  # GET /blog_images/new
  def new
    @blog_image = BlogImage.new
  end

  # GET /blog_images/1/edit
  def edit
  end

  # POST /blog_images
  # POST /blog_images.json
  def create
    @blog_image = BlogImage.new(blog_image_params)

    respond_to do |format|
      if @blog_image.save
        format.html { redirect_to @blog_image, notice: 'Blog image was successfully created.' }
        format.json { render :show, status: :created, location: @blog_image }
      else
        format.html { render :new }
        format.json { render json: @blog_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blog_images/1
  # PATCH/PUT /blog_images/1.json
  def update
    respond_to do |format|
      if @blog_image.update(blog_image_params)
        format.html { redirect_to @blog_image, notice: 'Blog image was successfully updated.' }
        format.json { render :show, status: :ok, location: @blog_image }
      else
        format.html { render :edit }
        format.json { render json: @blog_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_images/1
  # DELETE /blog_images/1.json
  def destroy
    @blog_image.destroy
    respond_to do |format|
      format.html { redirect_to blog_images_url, notice: 'Blog image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog_image
      @blog_image = BlogImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_image_params
      params.require(:blog_image).permit(:excite_url, :tumblr_id, :tumblr_info)
    end
end
