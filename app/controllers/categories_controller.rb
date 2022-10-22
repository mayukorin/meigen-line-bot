class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find(params[:id])
    @meigen = Meigen.where(category_id: @category.id).sample  
    session[:meigen] = @meigen
  end
end
