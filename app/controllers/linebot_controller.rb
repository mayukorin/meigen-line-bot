require 'line/bot'

class LinebotController < ApplicationController
    skip_before_action :verify_authenticity_token

    def client
        @client ||= Line::Bot::Client.new { |config|
            config.channel_id = ENV["LINE_CHANNEL_ID"]
            config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
            config.channel_token = ENV['LINE_CHANNEL_TOKEN']
        }
    end

    def callback
        body = request.body.read
        events = client.parse_events_from(body)
        events.each do |event|
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    schedule = event.message['text']
                    # meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_cloud_function(schedule)
                    
                    message = {
                        type: 'text',
                        # text: schedule+"，頑張ってください！\nそんなあなたに贈る名言は「"+meigen_body+"」です！"
                        text: "ok"
                    }
                    client.reply_message(event['replyToken'], message)
                end
            end
        end
        "OK"
    end
end
