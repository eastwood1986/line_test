require 'net/http'
require 'uri'
require 'json'

module Util
    # 定数
    WHEATER_API = "http://weather.livedoor.com/forecast/webservice/json/v1"
    
    # 説明メッセージ
    def get_desc_message
        desc_msssage = {
            type: "text",
            text: "-- 使い方 --\n検索キーワードを以下のように入力して下さい。\n(例)東京都や大阪府"
        }
        
        return desc_msssage        
    end
    
    # 天気予報取得
    def get_wheather_forecast(city)
        # テンプレート
        message = {type: "template", altText: "天気予報", template: {type: "carousel", columns: []}}

        # API呼出し
        uri = URI("#{WHEATER_API}?city=#{city}")
        json = Net::HTTP.get(uri)
        req = JSON.parse(json)
        
        # 要素取得
        link = req["link"]
        location = req["location"]
        forecasts = req["forecasts"]
        
        # 要素追加
        forecasts.each do |f|
            tmp_column = {}
            tmp_action = {}
            
            max = f["temperature"]["max"]
            min = f["temperature"]["min"]
            
            # nilエラー回避
            if max.instance_of?(NilClass) then
                max = {"celsius" => "不明"}
            end
            if min.instance_of?(NilClass) then
                min = {"celsius" => "不明"}
            end
            
            tmp_action.store(:type, "uri")
            tmp_action.store(:label, "詳細情報")
            tmp_action.store(:uri, link)
            tmp_column.store(:title, "#{location["city"]} #{f["date"]}(#{f["dateLabel"]})")
            tmp_column.store(:text, "天気予報: #{f["telop"]}\n最高気温:#{max["celsius"]}℃\n最低気温:#{min["celsius"]}℃")
            tmp_column.store(:actions, [])
            tmp_column[:actions].push(tmp_action)
            
            message[:template][:columns].push(tmp_column)
        end
        
        return message
    end
    
    # 都市一覧取得
    def get_city_list(prefecture)
        # テンプレート
        message = {"type": "template","altText": "都市一覧","template": {"type": "buttons","thumbnailImageUrl": "","text": "天気予報を表示する都市を選択して下さい。","actions": []}}
        
        # 地域情報取得
        infos = get_city_info(prefecture.to_sym)
        
        # 取得失敗
        if infos.nil? then
            return get_desc_message
        end
        
        detailIds = infos[:detailId].split(",")
        detailNames = infos[:detailName].split(",")
        image_url = infos[:imageUrl]
        
        # 要素設定
        message[:template][:thumbnailImageUrl] = image_url
        
        # 要素追加
        detailIds.each_with_index do |id, idx|
            tmp_action = {}
            tmp_action.store(:type, "postback")
            tmp_action.store(:label, detailNames[idx])
            tmp_action.store(:data, "city=#{detailIds[idx]}")
    
            message[:template][:actions].push(tmp_action)
        end
  
        return message
    end
    
    # 都市情報取得    
    def get_city_info(key)
        location = {
            "青森県": {"detailId": "020010,020020,020030","detailName": "青森,むつ,八戸","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/aomori.png"},
            "岩手県": {"detailId": "030010,030020,030030","detailName": "盛岡,宮古,大船渡","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/iwate.png"},
            "宮城県": {"detailId": "040010,040020","detailName": "仙台,白石","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/miyagi.png"},
            "秋田県": {"detailId": "050010,050020","detailName": "秋田,横手","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/akita.png"},
            "山形県": {"detailId": "060010,060020,060030,060040","detailName": "山形,米沢,酒田,新庄","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/yamagata.png"},
            "福島県": {"detailId": "070010,070020,070030","detailName": "福島,小名浜,若松","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/fukushima.png"},
            "茨城県": {"detailId": "080010,080020","detailName": "水戸,土浦","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/ibaragi.png"},
            "栃木県": {"detailId": "090010,090020","detailName": "宇都宮,大田原","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/tochigi.png"},
            "群馬県": {"detailId": "100010,100020","detailName": "前橋,みなかみ","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/gunma.png" },  
            "埼玉県": {"detailId": "110010,110020,110030","detailName": "さいまた,熊谷,秩父","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/saitama.png"},
            "千葉県": {"detailId": "120010,120020,120030","detailName": "千葉,銚子,館山","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/chiba.png"},
            "東京都": {"detailId": "130010,130020,130030,130040","detailName": "東京,大島,八丈島,父島","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/tokyo.png"},
            "神奈川県": {"detailId": "140010,140020","detailName": "横浜,小田原","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kanagawa.png"},
            "新潟県": {"detailId": "150010,150020,150030,150040","detailName": "新潟,長岡,高田,相川","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/niigata.png"},
            "富山県": {"detailId": "160010,160020","detailName": "富山,伏木","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/toyama.png"},
            "石川県": {"detailId": "170010,170020","detailName": "金沢,輪島","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/ishikawa.png"},
            "福井県": {"detailId": "180010,180020","detailName": "福井,敦賀","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/fukui.png"},
            "山梨県": {"detailId": "190010,190020","detailName": "甲府,河口湖","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/yamanashi.png"},
            "長野県": {"detailId": "200010,200020,200030","detailName": "長野,松本,飯田","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/nagano.png"},
            "岐阜県": {"detailId": "210010,210020","detailName": "岐阜,高山","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/gifu.png"},
            "静岡県": {"detailId": "220010,220020,220030,220040","detailName": "静岡,網代,三島,浜松","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/aichi.png"},
            "愛知県": {"detailId": "230010,230020","detailName": "名古屋,豊橋","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/aichi.png"},
            "三重県": {"detailId": "240010,240020","detailName": "津,尾鷲","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/mie.png"},
            "滋賀県": {"detailId": "250010,250020","detailName": "大津,彦根","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/shiga.png"},
            "京都府": {"detailId": "260010,260020","detailName": "京都,舞鶴","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kyoto.png"},
            "大阪府": {"detailId": "270000","detailName": "大阪","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/osaka.png" },
            "兵庫県": {"detailId": "280010,280020","detailName": "神戸,豊岡","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/hyougo.png"},
            "奈良県": {"detailId": "290010,290020","detailName": "奈良,風屋","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/nara.png"},
            "和歌山県": {"detailId": "300010,300020","detailName": "和歌山,潮岬","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/wakayama.png"},
            "鳥取県": {"detailId": "310010,310020","detailName": "鳥取,米子","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/tottori.png"},
            "島根県": {"detailId": "320010,320020,320030","detailName": "松江,浜田,西郷","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/shimane.png"},
            "岡山県": {"detailId": "330010,330020","detailName": "岡山,津山","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/okayama.png"},
            "広島県": {"detailId": "340010,340020","detailName": "広島,庄原","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/hiroshima.png"},
            "山口県": {"detailId": "350010,350020,350030,350040","detailName": "下関,山口,柳井,萩","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/yamaguchi.png"},
            "徳島県": {"detailId": "360010,360020","detailName": "徳島,日和佐","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/tokushima.png"},
            "香川県": {"detailId": "370000","detailName": "高松","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kagawa.png"},
            "愛媛県": {"detailId": "380010,380020,380030","detailName": "松山,新居浜,宇和島","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/ehime.png"},
            "高知県": {"detailId": "390010,390020,390030","detailName": "高知,室戸岬,清水","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kouchi.png"},
            "福岡県": {"detailId": "400010,400020,400030,400040","detailName": "福岡,八幡,飯塚,久留米","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/fukuoka.png"},
            "佐賀県": {"detailId": "410010,410020","detailName": "佐賀,伊万里","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/saga.png"},
            "長崎県": {"detailId": "420010,420020,420030,420040","detailName": "長崎,佐世保,厳原,福江","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/nagasaki.png" },
            "熊本県": {"detailId": "430010,430020,430030,430040","detailName": "熊本,阿蘇之姫,牛深,人吉","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kumamoto.png"},
            "大分県": {"detailId": "440010,440020,440030,440040","detailName": "大分,中津,日田,佐伯","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/ooita.png"},
            "宮崎県": {"detailId": "450010,450020,450030,450040","detailName": "宮崎,延丘,都城,高千穂","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/miyazaki.png"},
            "鹿児島県": {"detailId": "460010,460020,460030,460040","detailName": "鹿児島,鹿屋,種子島,名瀬","imageUrl": "https://s3-ap-northeast-1.amazonaws.com/prefecture/kagoshima.png"}
        }
        
        return location.dig(key)
    end

end