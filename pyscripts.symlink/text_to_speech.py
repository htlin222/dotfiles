import os
import azure.cognitiveservices.speech as speechsdk
from azure.cognitiveservices.speech import AudioDataStream, SpeechSynthesizer
from azure.cognitiveservices.speech.audio import AudioOutputConfig

# def text_to_speech(input_file):
# export SPEECH_KEY and SPEECH_REGION in your zshrc or zprofile
speech_config = speechsdk.SpeechConfig(subscription=os.environ.get('SPEECH_KEY'), region=os.environ.get('SPEECH_REGION'))
synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config)

SSML_SETTINGS = '<voice name="zh-TW-YunJheNeural"><prosody rate="15%" pitch="+5%">'
SSML_START = '<speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">'
SSML_END = '</prosody></voice></speak>'
# Test the voice: https://azure.microsoft.com/en-us/products/cognitive-services/text-to-speech/#features
def text_to_speech(input_file):
    with open(input_file) as f:
        lines = f.readlines()
    i = 1
    for text in lines:
        ssml = SSML_START + SSML_SETTINGS + text + SSML_END
        result = synthesizer.speak_ssml_async(ssml).get()
        stream = AudioDataStream(result)
        filename = "output/" + str(i) + '_' + text[0:9] + '.wav'
        stream.save_to_wav_file(filename)
        i = i + 1

if __name__=='__main__':
    input_file = 'yourTextHearToSpeech.txt'
    text_to_speech(input_file)
