class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find(params[:id])
    if @category.name == "オリジナルの名言"
      puts "oriorioriori"
      session[:meigen_id] = 0
    else
      @meigen_id = Meigen.where(category_id: @category.id).pluck(:id).sample  
      session[:meigen_id] = @meigen_id
    end
  end
end
