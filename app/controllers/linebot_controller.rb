require 'line/bot'

class LinebotController < ApplicationController
    skip_before_action :verify_authenticity_token

    @schedule_meigen_request_users = Hash.new

    BASIC_PLAN_FOR_JAPANESE = 'ベーシック'
    PREIUM_PLAN_FOR_JAPANESE = 'プレミアム'
    BASIC_PLAN_FOR_ENGLISH = 'basic'
    PREIUM_PLAN_FOR_ENGLISH = 'premium'

    def self.set_schedule_meigen_request_user(userId:, schedule:)
        @schedule_meigen_request_users.store(userId, schedule)
    end

    def self.get_schedule_for_request_user(userId:)
        @schedule_meigen_request_users[userId]
    end

    def self.remove_schedule_meigen_request_user(userId:)
        @schedule_meigen_request_users.delete(userId)
    end

    def client
        @client ||= Line::Bot::Client.new { |config|
            config.channel_id = ENV["LINE_CHANNEL_ID"]
            config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
            config.channel_token = ENV['LINE_CHANNEL_TOKEN']
        }
    end

    def mode_question_message
        mode_question_message = {
            type: 'template',
            altText: '名言を取得するモードを選択させる',
            template: {
                type: 'confirm',
                text: "モードを選んでください！\n・ベーシック：30秒ほどで予定に合う名言を選びます．とりあえず名言がほしい！という方にお勧めです．\n・プレミアム：1分30秒ほどじっくりかけて名言を選びます．その分より良い名言を選べるかもしれません．時間をかけてもいいから，自分に合った名言がほしいという方にお勧めです．",
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
    end

    def is_basic_or_premium_mode(selected_mode:)
        if selected_mode != PREIUM_PLAN_FOR_ENGLISH and selected_mode != BASIC_PLAN_FOR_ENGLISH
            return false
        end
        return true
    end

    def most_fit_meigen_for_schedule_message(selected_mode:, schedule:)
        begin
            meigen_body = OriginalAndScheduleMeigenFetcher.fetch_meigen_body_by_schedule_from_cloud_function(schedule: schedule, mode: selected_mode)
            message_text = schedule+"，頑張ってください！\nそんなあなたに贈る名言は「"+meigen_body+"」です！"
        rescue => exception
            message_text = "申し訳ありません．名言を選べませんでした．少し時間をおいてからもう一度お試しください．"
        end

        most_fit_meigen_for_schedule_message  = {
            type: 'text',
            text: message_text
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
                    if event.message['text'] == BASIC_PLAN_FOR_JAPANESE || event.message['text'] == PREIUM_PLAN_FOR_JAPANESE
                        puts 'this message is mode answer message. so, ignore'
                        return
                    end

                    LinebotController.set_schedule_meigen_request_user(userId: event['source']['userId'], schedule: event.message['text'])

                    client.reply_message(event['replyToken'], mode_question_message)
                end
            when Line::Bot::Event::Postback
                selected_mode = event['postback']['data']
                unless is_basic_or_premium_mode(selected_mode: selected_mode)
                    puts 'this message is sent by invalid route. so, ignore'
                    return
                end

                userId = event['source']['userId']
                schedule = LinebotController.get_schedule_for_request_user(userId: userId)
                client.reply_message(event['replyToken'], most_fit_meigen_for_schedule_message(selected_mode: selected_mode, schedule: schedule))

                LinebotController.remove_schedule_meigen_request_user(userId: userId)
            end
        end
        "OK"
    end
end
