


from openai import OpenAI

client = OpenAI(
    api_key="sk-H5kRUnT7NP0AbhZvFRAtHq0YBl7VsMEgRtetmguzOAhj9AlZ",
    base_url="https://api.moonshot.cn/v1",
)

def get_moon_chat_answer(query):

  completion = client.chat.completions.create(
    model="moonshot-v1-8k",
    messages=[ 
      {"role": "system", "content": "假设你是一位生物医学方面的院士，你精通药理学，拥有丰富的疾病知识，我将给你提供一段药物适应症的英文说明，请你从中提取出药物的英文适应症中与癌症或者肿瘤相关的适应症。请注意，你只需要输出符合要求的疾病的最简单的形式，不应当包含标点符号或者是换行符，也不应包含advanced或者local等描述疾病进展程度的单词，如果有多个符合要求的疾病，请用分号隔开，如果没有符合要求的疾病，请输出“non cancer”。"},
      {"role": "user", "content": query}
    ],
    temperature=0.2,
  )
  
  return(completion.choices[0].message.content)
