require 'net/http'

class OriginalAndScheduleMeigenFetcher

    def self.fetch_original_meigen_body_from_cloud_function
        body = {
            "new_meigen" => ""
        }.to_json
        http, req = setup_http_and_req(body)

        begin
            res = http.request(req)
            original_meigen_body = JSON.parse(res.body)
            return original_meigen_body
            
        rescue => exception
            puts exception.message
            raise Exception.new exception.message
        end
    end

    def self.fetch_meigen_body_by_schedule_from_cloud_function(schedule_name, mode)

        body = {
            "schedule" => schedule_name,
            "plan" => mode
        }.to_json
        http, req = setup_http_and_req(body)

        begin
            # raise ZeroDivisionError
            res = http.request(req)
            results = JSON.parse(res.body)
            meigen_body_for_schedule = results['most_fit_meigen']
            return meigen_body_for_schedule
        rescue => exception
            raise exception
        end
    end

    def self.setup_http_and_req(body)
        cloud_function_url = URI.parse("https://us-central1-eighth-ridge-348103.cloudfunctions.net/schedule_meigen") 

        http = Net::HTTP.new(cloud_function_url.host, cloud_function_url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout=120

        req = Net::HTTP::Post.new(cloud_function_url.request_uri)
        req["content-Type"] = "application/json"
        req.body = body

        return http, req
    end
end