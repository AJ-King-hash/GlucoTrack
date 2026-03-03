# from chatterbot import ChatBot
# from chatterbot.trainers import ListTrainer
# # Create the chatbot
# chatbot = ChatBot('HealthBot')  # or your preferred name

# # Create the trainer
# trainer = ListTrainer(chatbot)

# # Train with custom health advice pairs
# # Format: [ "User question", "Bot response" ]
# trainer.train([
#     "What is high blood sugar?",
#     "High blood sugar, or hyperglycemia, happens when your blood glucose level is too high. It's common in diabetes and can cause symptoms like thirst, fatigue, and blurred vision.",

#     "Why do I have high blood sugar?",
#     "Common causes include not enough insulin, eating too many carbs, stress, illness, or skipping medication. Check with your doctor.",

#     "What should I eat if I have high blood sugar?",
#     "Focus on low-glycemic foods: non-starchy veggies like broccoli and spinach, berries, nuts, lean proteins like fish or chicken, and whole grains like oats in moderation. Avoid sugary drinks and white bread.",

#     "How can I lower my blood sugar quickly?",
#     "Drink water, exercise lightly (like walking), take prescribed medication, and avoid carbs. If it's very high (>250 mg/dL) or you have symptoms like nausea, seek medical help immediately.",

#     "What are symptoms of high blood sugar?",
#     "Increased thirst, frequent urination, fatigue, headaches, blurred vision, slow-healing sores. Severe cases can lead to confusion or fruity breath — that's an emergency.",

#     "Is fruit bad for high blood sugar?",
#     "Not all fruit — choose low-GI ones like berries, apples, or cherries in moderation. Pair with protein or nuts to prevent spikes.",

#     "Can exercise help with blood sugar?",
#     "Yes! Even a short walk after meals can lower blood sugar. Aim for 150 minutes of moderate activity per week, but check with your doctor first.",

#     "What foods should I avoid with diabetes?",
#     "Limit sugary drinks, candy, white rice, white bread, potatoes, and processed snacks. They cause fast blood sugar spikes."
# ])

# # Optional: Train on more general conversations (after installing chatterbot-corpus)
# # from chatterbot.trainers import ChatterBotCorpusTrainer
# # corpus_trainer = ChatterBotCorpusTrainer(chatbot)
# # corpus_trainer.train("chatterbot.corpus.english")

# # Test it
# print(chatbot.get_response("What should I eat if I have high blood sugar?"))
# print(chatbot.get_response("What are symptoms of high blood sugar?"))