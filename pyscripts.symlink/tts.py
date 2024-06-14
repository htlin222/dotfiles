import os
import azure.cognitiveservices.speech as speechsdk

# This example requires environment variables named "SPEECH_KEY" and "SPEECH_REGION"
speech_config = speechsdk.SpeechConfig(subscription=os.environ.get('SPEECH_KEY'), region=os.environ.get('SPEECH_REGION'))
audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True)
# audio_config = speechsdk.audio.AudioOutputConfig(filename="~/file.wav")
# The language of the voice that speaks.
speech_config.speech_synthesis_voice_name='zh-TW-HsiaoChenNeural'

speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

# Get text from the console and synthesize to the default speaker.
print("Enter some text that you want to speak >")
# text = input()
text = '蔡總統說，中央氣象局已經在今天晚間8點30分，解除尼莎颱風海上警報。但是大家還是要加強警覺，不能掉以輕心。受到東北季風及颱風外圍環流影響，北部、東北部明天雨勢仍會有大雨或局部性豪雨；東北季風帶來的冷空氣，也會讓各地越晚越冷。'

speech_synthesis_result = speech_synthesizer.speak_text_async(text).get()

if speech_synthesis_result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
    print("Speech synthesized for text [{}]".format(text))
elif speech_synthesis_result.reason == speechsdk.ResultReason.Canceled:
    cancellation_details = speech_synthesis_result.cancellation_details
    print("Speech synthesis canceled: {}".format(cancellation_details.reason))
    if cancellation_details.reason == speechsdk.CancellationReason.Error:
        if cancellation_details.error_details:
            print("Error details: {}".format(cancellation_details.error_details))
            print("Did you set the speech resource key and region values?")
