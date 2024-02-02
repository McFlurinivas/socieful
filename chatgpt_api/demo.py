from openai import OpenAI
client = OpenAI()

response = client.chat.completions.create(
  model="gpt-3.5-turbo",
  str = input()
  messages=[
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "assitant", "content": "Hi, how are you?"},
    {"role": "assitant", "content": "From 1 to 10, rate how you are feeling"},
    {"role": "user", "content": str},
    {"role": "assistant", "content": "How many days you are feeling"},
    {"role": "user", "content": "Where was it played?"}
  ]
)