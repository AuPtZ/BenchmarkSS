import random
from http import HTTPStatus
import dashscope

dashscope.api_key="sk-e84c567acf26491ba2c65b00751d289d"

def call_with_messages(query):
    messages = [{'role': 'system', 'content': '假设你是一位生物医学方面的院士，你精通药理学，拥有丰富的疾病知识，我将给你提供一段药物适应症的英文说明，请你从中提取出药物的英文适应症中与癌症或者肿瘤相关的适应症。请注意，你只需要输出符合要求的疾病的最简单的形式，不应当包含标点符号或者是换行符，也不应包含advanced或者local等描述疾病进展程度的单词，如果有多个符合要求的疾病，请用分号隔开，如果没有符合要求的疾病，请输出“non cancer”。'},
                {'role': 'user', 'content': query}]
    response = dashscope.Generation.call(
        dashscope.Generation.Models.qwen_max,
        messages=messages,
        # set the random seed, optional, default to 1234 if not set
        seed=random.randint(1, 10000),
        # set the result to be "message" format.
        result_format='message',
    )
    if response.status_code == HTTPStatus.OK:
        return(response.output.choices[0].message.content)
    else:
        print("false!")
        return(response.message)



