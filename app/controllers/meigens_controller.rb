require 'net/http'

class MeigensController < ApplicationController
  def show_by_category
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
end
