from openai import OpenAI
import functools
import pandas as pd

API_KEY="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"

class GlucoBot():
    def __init__(self):
        self.client=OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key="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")

    def chat(self,message):
        completion = self.client.chat.completions.create(
        model="openrouter/aurora-alpha",
        messages=[
        {
          "role": "user",
        "content": message
       }
       ])
        return completion.choices[0].message.content
    def chatAsNumber(self,message):
        completion = self.client.chat.completions.create(
        model="openrouter/aurora-alpha",
        messages=[
        {
          "role": "user",
        "content": "give me the response as just the value of Glacymic load as number of this whole meal:"+message
       }
       ])
        return completion.choices[0].message.content
    def chatAsJSON(self,message):
        completion = self.client.chat.completions.create(
        model="openrouter/aurora-alpha",
        messages=[
        {
          "role": "user",
        "content": "give me the response as just as json format but give it to me as normal string  contains{'risk':'risk_value_here_Low_or_Medium_or_High_of_the_Glacymic_Load','analysed_at':'put_the_timestamp_of_the_current_time','gluco_percent':'the Glacymic Load'} and the Glacymic Load is the value of this meal description GL:"+str(message)
       }
       ])
        result= completion.choices[0].message.content
        splitter=result.split("json")[0].split(",")
        remove_rs=lambda xy:(xy!="\"" and  xy!="\'" and xy!="{" and xy!="}")
        pp=map(lambda x:functools.reduce(lambda x,y:x+y,list(filter(remove_rs,x))),splitter)
        dictionary=dict()
        def keyAndVal(value:str):
            key=value.split(":")[0]
            val=value.split(":")[1]
            dictionary.update({key:val})
        for i in pp:
            keyAndVal(i)
        return dictionary


# glucoBot=GlucoBot() 
# print(glucoBot.chat(
    # " i need apps in android to edit the video for the background and sounds in videos "
# ))
# res=glucoBot.chatAsJSON("tow cup of milks")

# date_str="2024-03-15T10"
# print((pd.to_datetime(date_str)))
# print(res)




