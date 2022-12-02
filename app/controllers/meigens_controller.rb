require 'net/http'

class MeigensController < ApplicationController
  @@meigen_bodies_for_schedule = {}

  def show_by_gacha
    @meigen_id = session[:meigen_id]
    
    @is_session_existed = session[:meigen_id] || session[:original_meigen_body]

    if @is_session_existed
      @is_original_meigen = session[:original_meigen_body]
      if @is_original_meigen
        @original_meigen_body = session[:original_meigen_body]
      else
        @meigen = Meigen.find(@meigen_id)
      end
    end
    render 'meigens/show'
  end

  def find_meigen_by_schedule
    meigen_body = Meigen.fetch_meigen_body_by_schedule_from_cloud_function(params[:schedule])
    meigen_model_for_schedule = Meigen.find_by(body: meigen_body)
    session[:meigen_id] = meigen_model_for_schedule.id
    render json: ""
  end

  def select_meigen_by_random_or_original
    gacha = Gacha.find_by(id: params[:gacha_id])
    if gacha.name == "オリジナルの名言"
      begin
        original_meigen_body = Meigen.fetch_original_meigen
        session[:original_meigen_body] = original_meigen_body
      rescue => exception
       puts exception
      end
    else
      random_meigen_id = Meigen.where(gacha_id: params[:gacha_id]).pluck(:id).sample
      session[:meigen_id] = random_meigen_id  
    end
    render json: ""
  end
end
