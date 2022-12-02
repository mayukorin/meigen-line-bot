class GachasController < ApplicationController
  def index
    @gachas = Gacha.all
  end

  def new_schedule
    render 'gachas/schedule_gacha/new_schedule'
  end

  def show
    gon.base_url = ENV['BASE_URL']
    @gacha = Gacha.find(params[:id])
    # if @gacha.name == "オリジナルの名言"
    #   session[:meigen_id] = 0
    # else
    #   @meigen_id = Meigen.where(gacha_id: @gacha.id).pluck(:id).sample  
    #   session[:meigen_id] = @meigen_id
    # end
  end

  def show_schedule_gacha
    gon.base_url = ENV['BASE_URL']
    @schedule = params[:schedule]
    render "gachas/schedule_gacha/show"
  end

end
