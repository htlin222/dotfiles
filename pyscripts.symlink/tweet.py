#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: tweet
# date: "2023-03-25"
# @raycast.title Tweet
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description

# @raycast.icon 🐦
# @raycast.mode silent
# @raycast.packageName System
# @raycast.schemaVersion 1

import os
import yaml
import tweepy
from pathlib import Path

# Get path to home directory
home_dir = str(Path.home())

# Define path to YAML file
yaml_path = os.path.join(home_dir, 'KEY', 'twitter.yaml')

# Load API keys and access tokens from YAML file
with open(yaml_path, 'r') as file:
    config = yaml.safe_load(file)

consumer_key = config['consumer_key']
consumer_secret = config['consumer_secret']
access_token = config['access_token']
access_token_secret = config['access_token_secret']

# Authenticate with Twitter API
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

# Create API object
api = tweepy.API(auth)

# Create a tweet
api.update_status("Hello Tweepy")
