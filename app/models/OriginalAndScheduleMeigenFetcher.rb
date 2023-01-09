require 'net/http'

class OriginalAndScheduleMeigenFetcher

    CLOUD_FUNCTION_URL_STRING = "https://us-central1-eighth-ridge-348103.cloudfunctions.net/schedule_meigen"
    TIME_OUT = 120

    def self.fetch_meigen_body_by_schedule_from_cloud_function(schedule:, mode:)

        body = {
            "schedule" => schedule,
            "plan" => mode
        }.to_json
        http, req = setup_http_and_req(body)

        begin
            res = http.request(req)
            results = JSON.parse(res.body)
            most_fit_meigen_body_for_schedule = results['most_fit_meigen']
            return most_fit_meigen_body_for_schedule
        rescue => exception
            raise exception
        end
    end

    def self.setup_http_and_req(body)
        cloud_function_url = URI.parse(CLOUD_FUNCTION_URL_STRING) 

        http = Net::HTTP.new(cloud_function_url.host, cloud_function_url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = TIME_OUT

        req = Net::HTTP::Post.new(cloud_function_url.request_uri)
        req["content-Type"] = "application/json"
        req.body = body

        return http, req
    end
end