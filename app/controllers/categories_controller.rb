class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def index_schedule_category
    render 'schedule_category_index'
  end

  def show
    @category = Category.find(params[:id])
    if @category.name == "オリジナルの名言"
      session[:meigen_id] = 0
    else
      @meigen_id = Meigen.where(category_id: @category.id).pluck(:id).sample  
      session[:meigen_id] = @meigen_id
    end
  end

  def show_schedule_category
    gon.base_url = ENV['BASE_URL']
    @schedule = params[:schedule]
    render "schedule_category_show"
  end

end
