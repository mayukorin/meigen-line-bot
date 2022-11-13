require 'net/http'

class MeigensController < ApplicationController
  @@meigen_bodies_for_schedule = {}

  def show_by_gacha
    @meigen_id = session[:meigen_id]
    
    @is_session_existed = true
    @is_original = false

    if @meigen_id.nil?
      @is_session_existed = false
    else
      if @meigen_id == 0
        @is_original = true

        url = URI.parse("https://us-central1-eighth-ridge-348103.cloudfunctions.net/meigen-recomment")
          
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout=120
  
        req = Net::HTTP::Post.new(url.request_uri)
        req["content-Type"] = "application/json"
        body = {
            "new_meigen" => ""
        }.to_json
        req.body = body
  
        begin
            res = http.request(req)
            results = JSON.parse(res.body) 
            puts results
            @meigen = results
            
        rescue => exception
            puts exception.message
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
      
      today_all_schedules = []
      today_schedules = []
      today_schedules.push(params[:schedule])
      today_all_schedules.push(today_schedules)

      url = URI.parse("https://us-central1-eighth-ridge-348103.cloudfunctions.net/meigen-recomment")
          
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout=120

      req = Net::HTTP::Post.new(url.request_uri)
      req["content-Type"] = "application/json"
      body = {
          "schedules" => today_all_schedules
      }.to_json
      req.body = body

      meigen_body_for_schedule = ""

      begin
        res = http.request(req)
        results = JSON.parse(res.body) 
        puts results
        meigen_body_for_schedule = results[0]
        @@meigen_bodies_for_schedule.store(params[:schedule], meigen_body_for_schedule)
      rescue => exception
          puts "errorrrr"
          puts exception.message
      end

    end

    render json: "名言探し中(非同期でThread内実行中）"
  end

  def set_meigen_for_schedule_to_session
    meigen_model_for_schedule = Meigen.find_by(body: @@meigen_bodies_for_schedule[params[:schedule]])
    session[:meigen_id] = meigen_model_for_schedule.id
    render json: ""
  end
  
end
