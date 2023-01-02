require 'line/bot'

class LinebotController < ApplicationController
    skip_before_action :verify_authenticity_token

    @schedule_meigen_request_users = Hash.new

    def self.set_schedule_meigen_request_user(userId)
        @schedule_meigen_request_users.store(userId, true)
    end

    def self.remove_schedule_meigen_request_user(userId)
        @schedule_meigen_request_users.delete(userId)
    end

    def self.is_schedule_meigen_request_user(userId)
        @schedule_meigen_request_users.include?(userId)
    end

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
                    userId = event["source"]["userId"]
                    if LinebotController.is_schedule_meigen_request_user(userId)
                        message_text = "少々お待ちください。"
                        message = {
                            type: 'text',
                            text: message_text
                        }
                        client.reply_message(event['replyToken'], message)
                    else
                        LinebotController.set_schedule_meigen_request_user(userId)
                        schedule = event.message['text']
                        # meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_cloud_function(schedule)
                        meigen_body = "aaa"
                        sleep(10)
                        message_text = schedule+"，頑張ってください！\nそんなあなたに贈る名言は「"+meigen_body+"」です！"
                        message = {
                            type: 'text',
                            text: message_text
                        }
                        client.reply_message(event['replyToken'], message)
                        LinebotController.remove_schedule_meigen_request_user(userId)
                    end
                end
            end
        end
        "OK"
    end
end
