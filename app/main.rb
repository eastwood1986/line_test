require 'sinatra'
require 'line/bot'
require './app/utility'
include Util

# 初期化
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

# メイン
post '/callback' do
  body = request.body.read
  
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  
  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message # Messageの場合
      case event.type
      when Line::Bot::Event::MessageType::Text # Textの場合
        message = get_city_list(event.message['text'])
      else # Text以外の場合
        message = get_desc_message
      end
    when Line::Bot::Event::Postback # Postbackの場合
      city = event['postback']['data'].split("=")[1]
      message = get_wheather_forecast(city)
    else # Message, Postback以外の場合
      message = get_desc_message
    end
    
    client.reply_message(event['replyToken'], message)
  }
  
end

