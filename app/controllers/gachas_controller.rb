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
  end

  def show_schedule_gacha
    gon.base_url = ENV['BASE_URL']
    @schedule = params[:schedule]
    render "gachas/schedule_gacha/show"
  end

end
