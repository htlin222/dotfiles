import openai
import pyperclip as pc
from yaml import load, SafeLoader
text = pc.paste()
# Set the OpenAI API key
with open("openai_api.yaml","r",encoding="UTF-8") as settings_file:
    settings = load(settings_file,SafeLoader)
    openai.api_key = settings['api']

# Use the GPT-3 model to generate text
response = openai.Completion.create(
    engine="text-davinci-002",
    prompt=text,
    max_tokens=1024,
    temperature=0.5,
)

# Print the generated text
print(response["choices"][0]["text"])
