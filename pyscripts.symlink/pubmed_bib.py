#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: pubmed_bib
# date: "2023-03-18"

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
pubmed_dict = {}
authors = {}
years = {}
volumes = {}
issues = {}
journals = {}

for pmid in pmids:
    title = fetch.article_by_pmid(pmid).title
    authors = fetch.article_by_pmid(pmid).authors
    pub_date= fetch.article_by_pmid(pmid).year
    volume = fetch.article_by_pmid(pmid).volume
    issues[pmid] = fetch.article_by_pmid(pmid).issue
    journal = fetch.article_by_pmid(pmid).journal
    doi = fetch.article_by_pmid(pmid).doi
    pubmed_dict[pmid] = f"@article{{{pmid},\n  title = {{{title}}},\n  author = {{{', and '.join(authors)}}},\n  journal = {{{journal}}},\n  year = {{{pub_date}}},\n  volume = {{{volume}}},\n  doi = {{{doi}}},\n}}\n"
    print(f"PUBMED: {title} DONE")

# Get the current date and time
now = datetime.datetime.now()
current_date = now.strftime("%Y-%m-%d_%H-%M-%S")

# Rename the file
file_name = current_date + '_NEJM.bib'
full_file_path = os.path.join(os.environ['HOME'], 'Downloads', file_name)
# Combine the folder path and file name to create the full file path
# Write the BibTeX entries to a file
with open(full_file_path, "w") as bibfile:
    for entry in pubmed_dict.values():
        bibfile.write(entry)
