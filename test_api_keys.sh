#!/bin/bash

# VTS API Tester
# Use this script to verify your API keys and model availability before using the app.

echo "🎙️  VTS API Tester"
echo "=================="

PS3="Select a provider to test (enter number): "
options=("SiliconFlow" "BigModel" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "SiliconFlow")
            echo
            read -p "Enter your SiliconFlow API Key: " api_key
            echo "Testing 'FunAudioLLM/SenseVoiceSmall'..."

            # Create a dummy audio file (1 second of silence) for testing
            # Note: This requires ffmpeg. If not available, we'll try to warn.
            if ! command -v ffmpeg &> /dev/null; then
                echo "⚠️  ffmpeg not found. Cannot generate test audio."
                echo "Please verify you have a valid audio file named 'test.wav' in this directory or install ffmpeg."
                echo "Skipping test."
                break
            fi

            ffmpeg -f lavfi -i "anullsrc=r=16000:cl=mono" -t 1 -q:a 9 -acodec libmp3lame test.mp3 -y -hide_banner -loglevel error

            response=$(curl -s -X POST https://api.siliconflow.cn/v1/audio/transcriptions \
              -H "Authorization: Bearer $api_key" \
              -H "Content-Type: multipart/form-data" \
              -F "file=@test.mp3" \
              -F "model=FunAudioLLM/SenseVoiceSmall")

            echo "Response:"
            echo "$response"

            if [[ "$response" == *"text"* ]]; then
                echo "✅ SiliconFlow API Check Passed!"
            else
                echo "❌ SiliconFlow API Check Failed."
            fi

            rm test.mp3
            break
            ;;

        "BigModel")
            echo
            read -p "Enter your BigModel (ZhipuAI) API Key: " api_key
            echo "Testing 'glm-asr-2512'..."

            if ! command -v ffmpeg &> /dev/null; then
                 echo "⚠️  ffmpeg not found. Cannot generate test audio."
                 break
            fi

            # BigModel usually expects wav or mp3
            ffmpeg -f lavfi -i "anullsrc=r=16000:cl=mono" -t 1 -acodec pcm_s16le test.wav -y -hide_banner -loglevel error

            response=$(curl -s -X POST https://api.z.ai/api/paas/v4/audio/transcriptions \
              -H "Authorization: Bearer $api_key" \
              -H "Content-Type: multipart/form-data" \
              -F "file=@test.wav" \
              -F "model=glm-asr-2512")

            echo "Response:"
            echo "$response"

            if [[ "$response" == *"text"* ]]; then
                echo "✅ BigModel API Check Passed!"
            else
                echo "❌ BigModel API Check Failed."
            fi

            rm test.wav
            break
            ;;

        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
