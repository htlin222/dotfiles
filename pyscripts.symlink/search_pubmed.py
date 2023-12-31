#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: pubmed
# date: "2023-03-18"
# @raycast.title Pubmed search
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description

# @raycast.icon 🔍
# @raycast.mode silent
# @raycast.packageName System
# @raycast.schemaVersion 1
# @raycast.argument1 { "type": "text", "placeholder": "query" }

import datetime
import pandas as pd
from metapub import PubMedFetcher
import os

# journal = "${1// /%20}"
journal = "NEJM"
keyword=f"{journal}[journal] AND \"last 1 month\"[EDat] AND (fha[Filter])"
num_of_articles=3

fetch = PubMedFetcher()

pmids = fetch.pmids_for_query(keyword, retmax=num_of_articles)

# get  articles
articles = {}
titles = {}
abstracts = {}
citations = {}
links = {}
dois = {}
bibdic = {}

for pmid in pmids:
    articles[pmid] = fetch.article_by_pmid(pmid)
    titles[pmid] = fetch.article_by_pmid(pmid).title
    abstracts[pmid] = fetch.article_by_pmid(pmid).abstract
    citations[pmid] = fetch.article_by_pmid(pmid).citation
    dois[pmid] = fetch.article_by_pmid(pmid).doi
    links[pmid] = "https://pubmed.ncbi.nlm.nih.gov/"+pmid+"/"
    print(f"PUBMED: {pmid} DONE")

Abstract = pd.DataFrame(list(abstracts.items()),columns = ['pmid','Abstract'])
Title = pd.DataFrame(list(titles.items()),columns = ['pmid','Title'])
Citation = pd.DataFrame(list(citations.items()),columns = ['pmid','Citation'])
Link = pd.DataFrame(list(links.items()),columns = ['pmid','Link'])
DOI = pd.DataFrame(list(dois.items()),columns = ['pmid','doi'])

data_frames = [Title,Abstract,Citation,Link,DOI]
from functools import reduce
df_merged = reduce(lambda  left,right: pd.merge(left,right,on=['pmid'],
                                            how='outer'), data_frames)
# Get the current date and time
now = datetime.datetime.now()
current_date = now.strftime("%Y-%m-%d_%H-%M-%S")

# Rename the file
file_name = current_date + '_NEJM.csv'
full_file_path = os.path.join(os.environ['HOME'], 'Downloads', file_name)
# Combine the folder path and file name to create the full file path

# Save the DataFrame to the CSV file
df_merged.to_csv(full_file_path, index=False)
