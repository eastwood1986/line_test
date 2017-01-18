require 'cgi'
require 'json'
require 'line/bot'

# CGIの生成
$cgi = CGI.new()

# 送信されたデータの整形
params = {}
$cgi.params.each {|key, val|
  params = JSON.parse(key)
}

# 返信に必要な情報の取得
replyToken = params["events"][0]["replyToken"]
msgType = params["events"][0]["message"]["type"]

if msgType == "sticker" then
  msgText = "イイね！"
else
  msgText = params["events"][0]["message"]["text"]
end

# 返信データの作成
message = {
  type: 'text',
  text: msgText
}

# データ送信
client = Line::Bot::Client.new { |config|
    config.channel_secret = "4e98b0c536ea3e99d64f5e8c868971f0"
    config.channel_token = "Dw9Pb0VKuVvkq8QRV3tMguVscfVljPRIF3tiWTKzc+11SvWsLGzYvMaUBmsbNAoAUFH20tnY8WGXfTxdQXjD3dp4JpR6Et8hTKVlmkqzc094AqfunVNjrH5oOSIINFcVzrQhH22cVu1BAcxxBZMzQAdB04t89/1O/w1cDnyilFU="
}
response = client.reply_message(replyToken, message)
#p response

# 初期認証用コード
puts <<EOF
Content-type: text/html

linebot
EOF