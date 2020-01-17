class Admin::PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      TagPosts::UpdatePostTags.execute!(@post, tag_names)
      redirect_to admin_post_path(@post), notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])

    render :new
  end

  def update
    @post = Post.find(params[:id])

    if @post.update(post_params)
      TagPosts::UpdatePostTags.execute!(@post, tag_names)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def publish
    @post = Post.find(params[:id])

    if @post.published!
      redirect_to @post, notice: 'Post was published?'
    else
      redirect_to @post, notice: 'Maybe something is missing?'
    end
  end

  def destroy
    post = Post.find(params[:id])
    post_title = post.title

    if post.destroy
      redirect_to posts_url, notice: "#{post_title} was successfully destroyed."
    else
      redirect_to posts_path
    end
  end

  def show
    @post = Post.find(params[:id])
    render 'posts/show', post: @post
  end

  private

  def tag_names
    tag_params.fetch(:tags, '').split(', ')
  end

  def tag_params
    params.require(:post).permit(:tags)
  end

  def post_params
    params.require(:post).permit(:title, :body, :intro, :cover_image)
  end
end
