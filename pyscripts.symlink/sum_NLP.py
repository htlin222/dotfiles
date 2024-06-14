#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: sum_NLP
# date: "2023-02-21"

import nltk
nltk.download('punkt')
nltk.download('stopwords')
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, sent_tokenize
from nltk.stem import PorterStemmer

def summarize(text, n):
    # Tokenize the text into sentences and words
    sentences = sent_tokenize(text)
    words = word_tokenize(text)

    # Remove stopwords and punctuations
    stop_words = set(stopwords.words('english'))
    words = [word for word in words if word.lower() not in stop_words and word.isalnum()]

    # Stem the words using PorterStemmer
    stemmer = PorterStemmer()
    words = [stemmer.stem(word) for word in words]

    # Create a frequency distribution of words
    freq_dist = nltk.FreqDist(words)

    # Get the n most frequent words
    top_words = [word for word, freq in freq_dist.most_common(n)]

    # Create the summary by selecting sentences that contain the top words
    summary = []
    for sentence in sentences:
        sentence_words = word_tokenize(sentence)
        sentence_words = [stemmer.stem(word) for word in sentence_words]
        if any(word in sentence_words for word in top_words):
            summary.append(sentence)

    return ' '.join(summary)


if __name__ == '__main__':
    text = 'Aspiration pneumonia refers to adverse pulmonary consequences due to entry of gastric or oropharyngeal fluids, which may contain bacteria and/or be of low pH, or exogenous substances (eg, ingested food particles or liquids, mineral oil, salt or fresh water) into the lower airways [1]. The predisposing conditions, clinical syndromes, diagnosis, and treatment of aspiration pneumonia will be reviewed here. Community-acquired pneumonia, hospital-acquired pneumonia, empyema, and lung abscess are discussed separately.'
    print(summarize(text,1))

