require 'line/bot'

class LinebotController < ApplicationController
    skip_before_action :verify_authenticity_token

    @schedule_meigen_request_users = Hash.new

    BASIC_PLAN_FOR_JAPANESE = 'ベーシック'
    PREIUM_PLAN_FOR_JAPANESE = 'プレミアム'
    BASIC_PLAN_FOR_ENGLISH = 'basic'
    PREIUM_PLAN_FOR_ENGLISH = 'premium'

    def self.set_schedule_meigen_request_user(userId, schedule)
        @schedule_meigen_request_users.store(userId, schedule)
    end

    def self.get_schedule_for_request_user(userId)
        @schedule_meigen_request_users[userId]
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
                    userId = event['source']['userId']

                    if event.message['text'] == BASIC_PLAN_FOR_JAPANESE || event.message['text'] == PREIUM_PLAN_FOR_JAPANESE
                        puts 'this message is mode answer message. so, ignore'
                        return
                    end

                    schedule = event.message['text']
                    LinebotController.set_schedule_meigen_request_user(userId, schedule)

                    mode_question_message = {
                        type: 'template',
                        altText: '名言を取得するモードを選択させる',
                        template: {
                            type: 'confirm',
                            text: '名言を取得するモードを選んでください！',
                            actions: [
                                {
                                    type: 'postback',
                                    label: BASIC_PLAN_FOR_JAPANESE,
                                    data:  BASIC_PLAN_FOR_ENGLISH,
                                    text: BASIC_PLAN_FOR_JAPANESE
                                },
                                {
                                    type: 'postback',
                                    label: PREIUM_PLAN_FOR_JAPANESE,
                                    data: PREIUM_PLAN_FOR_ENGLISH,
                                    text: PREIUM_PLAN_FOR_JAPANESE
                                }
                            ]
                        }
                    }

                    client.reply_message(event['replyToken'], mode_question_message)


                    # if LinebotController.is_schedule_meigen_request_user(userId)
                    #     message_text = "ぴったりな名言を選び中ですので少々お待ちください。"
                    #     message = {
                    #         type: 'text',
                    #         text: message_text
                    #     }
                    #     client.reply_message(event['replyToken'], message)
                    # else
                    #     LinebotController.set_schedule_meigen_request_user(userId)
                    #     schedule = event.message['text']
                    #     meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_cloud_function(schedule)

                    #     message_text = schedule+"，頑張ってください！\nそんなあなたに贈る名言は「"+meigen_body+"」です！"
                    #     message = {
                    #         type: 'text',
                    #         text: message_text
                    #     }
                    #     client.reply_message(event['replyToken'], message)

                    #     LinebotController.remove_schedule_meigen_request_user(userId)
                    # end
                end
            when Line::Bot::Event::Postback
                schedule = LinebotController.get_schedule_for_request_user(event['source']['userId'])

                case event['postback']['data']
                when PREIUM_PLAN_FOR_ENGLISH
                    meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_premium_cloud_function(schedule)
                when BASIC_PLAN_FOR_ENGLISH
                    meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_basic_cloud_function(schedule)
                end

                message_text = schedule+"，頑張ってください！\nそんなあなたに贈る名言は「"+meigen_body+"」です！"
                message = {
                    type: 'text',
                    text: message_text
                }
                client.reply_message(event['replyToken'], message)
                LinebotController.remove_schedule_meigen_request_user(userId)
            end
        end
        "OK"
    end
end
