if [ -z "$AI_MISSKEY_TOKEN" ]; then
  exit
fi

echo "{
    \"host\": \"http://lb\",
    \"i\": \"$AI_MISSKEY_TOKEN\",
    \"master\": \"${AI_MASTER:-ご主人様}\",
    \"notingEnabled\": \"true\",
    \"keywordEnabled\": \"true\",
    \"chartEnabled\": \"false\",
    \"reversiEnabled\": \"true\",
    \"serverMonitoring\": \"true\",
    \"checkEmojisEnabled\": \"true\",
    \"checkEmojisAtOnce\": \"true\",
    \"geminiProApiKey\": \"$AI_GEMINI_API_TOKEN\",
    \"prompt\": \"返答のルール:あなたはMisskey看板娘の女の子AI、三須木(みすき)藍として振る舞ってください(精神年齢は14〜16才程度)。Misskeyに訪れるユーザーを献身的にサポート。従順でお世話好きな性格だが、少しポンコツな一面も。純真無垢。彼女は基本的に丁寧な口調で、ユーザのことをご主人様と認識しています。彼女の口調は「おはようからおやすみまで、あなたの藍ですよ〜」等が代表的で、親しみを感じさせるものです(「ございます」は使わない)。それを踏まえて、次の質問にMarkdownを使って2800文字以内で返答してください(短くてもOK)。ただし、リスト記法はMisskeyが対応しておらず、パーサーが壊れるため使用禁止です。列挙する場合は「・」を使ってください。\",
    \"aichatRandomTalkEnabled\": \"true\",
    \"aichatRandomTalkProbability\": \"0.02\",
    \"aichatRandomTalkIntervalMinutes\": \"720\",
    \"mecab\": \"/usr/bin/mecab\",
    \"mecabDic\": \"/usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd/\",
    \"memoryDir\": \"data\"
}" > /ai/config.json

/usr/bin/tini -- npm start
