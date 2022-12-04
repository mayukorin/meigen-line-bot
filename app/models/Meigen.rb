require 'net/http'

class Meigen < ApplicationRecord

    belongs_to :gacha
    belongs_to :author

    def self.fetch_original_meigen_body_from_cloud_function
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
            original_meigen_body = JSON.parse(res.body) 
            puts original_meigen_body
            return original_meigen_body
            
        rescue => exception
            puts exception.message
            raise Exception.new exception.message
        end
    end

    def self.fetch_meigen_body_by_schedule_from_cloud_function(schedule_name)
        today_all_schedules = []
        today_schedules = []
        today_schedules.push(schedule_name)
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
            return meigen_body_for_schedule
        rescue => exception
            puts exception.message

            raise Exception.new exception.message
        end
    end
end