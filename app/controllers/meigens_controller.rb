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

  def find_meigen_by_schedule
    meigen_body = Meigen.fetch_meigen_body_by_schedule_from_cloud_function(params[:schedule])
    meigen_model_for_schedule = Meigen.find_by(body: meigen_body)
    session[:meigen_id] = meigen_model_for_schedule.id
    render json: ""
  end
end
