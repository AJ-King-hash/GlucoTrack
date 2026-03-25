from openai import OpenAI
import functools
from datetime import datetime
import json
import re
import os

class GlucoBot():
    def __init__(self):
        self.client=OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key="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")

    def chat(self,message):
        completion = self.client.chat.completions.create(
        model="stepfun/step-3.5-flash:free",
        messages=[
        {
          "role": "user",
        "content": message
       }
       ])
        return completion.choices[0].message.content
    
    def chatAsNumber(self,message):
        completion = self.client.chat.completions.create(
        model="stepfun/step-3.5-flash:free",
        messages=[
        {
          "role": "user",
        "content": "give me the response as just the value of Glacymic load as number of this whole meal:"+message
       }
       ])
        return completion.choices[0].message.content
    
    def chatAsJSON(self,message):
        """
        Analyze meal and return detailed JSON with:
        - risk: Low/Medium/High based on Glycemic Load
        - gluco_percent: The Glycemic Load value (0-100+ scale)
        - analysed_at: Current timestamp in ISO 8601 format
        - recommendations: Health recommendations based on the meal
        - meal_tips: Specific tips for this meal type
        """
        current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
        
        # Default fallback response in case API fails
        fallback_response = {
            'risk': 'Medium',
            'gluco_percent': 10.0,
            'analysed_at': current_time,
            'recommendations': 'Maintain a balanced diet',
            'meal_tips': 'Consider pairing with protein or fiber'
        }
        
        try:
            # Enhanced prompt for more detailed analysis
            analysis_prompt = f"""
            Analyze this meal description and provide a detailed JSON response.
            
            Meal: {message}
            
            Provide a JSON with exactly these fields (no additional text):
            {{
                "risk": "Low" or "Medium" or "High" based on Glycemic Load,
                "gluco_percent": numeric value (0-100+ where <10=Low, 10-19=Medium, 20+=High),
                "analysed_at": "{current_time}",
                "recommendations": "2-3 sentence health recommendation",
                "meal_tips": "specific tips for this meal type"
            }}
            
            Guidelines:
            - Low GL (<10): Healthy choice, maintain this pattern
            - Medium GL (10-19): Moderate impact, consider portion control
            - High GL (20+): High impact, suggest alternatives
            - Consider meal timing (fasting, before meal, after meal)
            """
            
            completion = self.client.chat.completions.create(
            model="stepfun/step-3.5-flash:free",
            messages=[
            {
              "role": "user",
            "content": analysis_prompt
           }
           ])
            result = completion.choices[0].message.content
            
            # Parse the JSON response
            try:
                # Try to extract JSON from the response
                json_match = re.search(r'\{.*\}', result, re.DOTALL)
                if json_match:
                    json_str = json_match.group(0)
                    # Fix common JSON issues
                    json_str = json_str.replace("'", '"').replace('\n', ' ').replace('\r', '')
                    parsed = json.loads(json_str)
                    
                    # Ensure required fields exist
                    return {
                        'risk': parsed.get('risk', 'Medium'),
                        'gluco_percent': float(parsed.get('gluco_percent', 10.0)),
                        'analysed_at': parsed.get('analysed_at', current_time),
                        'recommendations': parsed.get('recommendations', 'Maintain a balanced diet'),
                        'meal_tips': parsed.get('meal_tips', 'Consider pairing with protein or fiber')
                    }
            except Exception as e:
                pass
            
            # Fallback: Parse manually if JSON parsing fails
            splitter=result.split("json")[0].split(",")
            remove_rs=lambda xy:(xy!="\"" and  xy!="'" and xy!="{" and xy!="}")
            pp=map(lambda x:functools.reduce(lambda x,y:x+y,list(filter(remove_rs,x))),splitter)
            dictionary=dict()
            def keyAndVal(value:str):
                if ':' in value:
                    key=value.split(":")[0].strip()
                    val=":".join(value.split(":")[1:]).strip().strip('"').strip("'")
                    dictionary.update({key:val})
            for i in pp:
                keyAndVal(i)
            return dictionary
            
        except Exception as e:
            # Catch all exceptions (API errors, authentication errors, etc.) and return fallback
            print(f"GlucoBot API error: {str(e)}")
            return fallback_response


# glucoBot=GlucoBot() 
# print(glucoBot.chatAsJSON(
    # "two kg of meat and salmon with cheese and 2 kg of sugar"
# ))
# res=glucoBot.chatAsJSON("tow cup of milks")



# date_str="2024-03-15T10"
# print((pd.to_datetime(date_str)))
# print(res)