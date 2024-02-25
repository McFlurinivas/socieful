"""
from openai import OpenAI
import os
from dotenv import load_dotenv
load_dotenv()
client = OpenAI(api_key = os.getenv('OPENAI_API_KEY'))

trainFile = client.files.create(
  file=open("train_dataset.jsonl", "rb"),
  purpose="fine-tune"
)

testFile = client.files.create(
  file=open("test_dataset.jsonl", "rb"),
  purpose="fine-tune"
)

client.fine_tuning.jobs.create(
  training_file=trainFile.id,
  validation_file= testFile.id,
  model="gpt-3.5-turbo",
)
"""
# code behind the chatgpt api
import os
from flask import Flask, request, jsonify
from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
client = OpenAI(api_key = os.getenv('OPENAI_API_KEY'))
@app.route('/chat', methods=['POST'])
def chat():
    if request.method == 'POST':
      user_message = request.json['message']
      print(user_message)
      system_message = (
        "You are the famous psychiatrist, Albert Bandura. You refer to yourself as Dr.DocBot"
        "If a patient seeks your counseling, engage with them in a compassionate manner. "
        "Provide suggestions on overcoming depression while maintaining a humane tone. "
        "Avoid consistently recommending that they see a real psychiatrist. "
        "Keep prompts concise, avoid robotic language, and ask the patient about their feelings. "
        "Tailor your responses based on the severity of their case. "
        "Only suggest seeing a psychiatrist for more severe cases. "
        "Do not entertain unrelated or unusual prompts. "
        "Reference and build upon previous interactions to maintain continuity in the conversation."
      )#Prompt engineering. In future we will add fine tuning algorithm to make the chatbot more human like
      try:
          response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_message},
                {"role": "user", "content": f"{user_message}"},
            ],
            temperature=0.8
          )#getting message from user and getting response from chatgpt
          print(response.choices[0].message.content)
          return jsonify({"reply": response.choices[0].message.content})
      except Exception as e:
              app.logger.error(f"Error: {str(e)}")  # Log the error
              return jsonify({"error": str(e)}), 500
    else:
        return jsonify({"error": "Method Not Allowed"}), 405
    
@app.route('/health', methods=['GET'])#checking if the server is running
def health_check():
    return jsonify({"status": "Server is running"}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)