require 'net/http'

class MeigensController < ApplicationController
  @@meigen_bodies_for_schedule = {}

  def show_by_gacha
    @meigen_id = session[:meigen_id]
    
    @is_session_existed = true

    if @meigen_id.nil?
      @is_session_existed = false
    else
      @is_original_meigen = false

      if @meigen_id == 0
        @is_original_meigen = true
        begin
          @original_meigen_body = Meigen.fetch_original_meigen
        rescue => exception
          @is_session_existed = false
        end

      else
        @meigen = Meigen.find(@meigen_id)
      end
    end
    render 'meigens/show'
  end

  def async_find_meigen_by_schedule
    
    Thread.start do

      begin
        @@meigen_bodies_for_schedule.store(params[:schedule], Meigen.fetch_meigen_by_schedule(params[:schedule]))
        puts "完了"
      rescue => exception
          puts exception.message
      end

    end

    render json: "名言探し中(非同期でThread内実行中）"
  end

  def set_meigen_for_schedule_to_session
    puts "取り出し開始"
    meigen_model_for_schedule = Meigen.find_by(body: @@meigen_bodies_for_schedule[params[:schedule]])
    session[:meigen_id] = meigen_model_for_schedule.id
    render json: ""
  end
  
end
