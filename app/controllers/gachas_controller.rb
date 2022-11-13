class GachasController < ApplicationController
  def index
    @gachas = Gacha.all
  end

  def index_schedule_gacha
    render 'schedule_gacha_index' # indexではない方が良いかも schedule 入力だから 予定に合うガチャを作ろう
  end

  def show
    @gacha = Gacha.find(params[:id])
    if @gacha.name == "オリジナルの名言"
      session[:meigen_id] = 0
    else
      @meigen_id = Meigen.where(gacha_id: @gacha.id).pluck(:id).sample  
      session[:meigen_id] = @meigen_id
    end
  end

  def show_schedule_gacha
    gon.base_url = ENV['BASE_URL']
    @schedule = params[:schedule]
    render "schedule_gacha_show"
  end

end
