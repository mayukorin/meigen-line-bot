class MeigensController < ApplicationController
  @@meigen_bodies_for_schedule = {}

  def take_out
    @is_session_existed = !session[:meigen_id].nil? || !session[:original_meigen_body].nil?

    unless @is_session_existed
      render 'meigens/show' and return
    end

    @is_original_meigen = !session[:original_meigen_body].nil?
    if @is_original_meigen
      @original_meigen_body = session[:original_meigen_body]
      session.delete(:original_meigen_body)
    else
      @meigen = Meigen.find(session[:meigen_id])
      session.delete(:meigen_id)
    end

    render 'meigens/show'
  end

  def select_by_schedule
    meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_cloud_function(params[:schedule])
    meigen_model_for_schedule = Meigen.find_by(body: meigen_body)
    session[:meigen_id] = meigen_model_for_schedule.id
    render json: ""
  end

  def select_by_random_or_original
    gacha = Gacha.find_by(id: params[:gacha_id])
    if gacha.name == "オリジナルの名言"
      begin
        original_meigen_body = OriginalAndScheduleMeigenFetcher.fetch_original_meigen_body_from_cloud_function
        session[:original_meigen_body] = original_meigen_body
        render json: original_meigen_body and return
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
