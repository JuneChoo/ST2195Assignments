import pandas as pd
import urllib.request as urrequest
from bs4 import BeautifulSoup as bs

def wiki_scraper():
    link =  "https://en.wikipedia.org/wiki/Comma-separated_values"
    req = urrequest.Request(link)
    response = urrequest.urlopen(req)
    web_content_raw = response.read().decode('utf-8')
    web_content_parsed = bs(web_content_raw, features="lxml")
    tb_table = web_content_parsed.body.find('table', attrs={'class': 'wikitable'})
    df = pd.read_html(str(tb_table))[0]
    df.to_csv("scraper_result.csv")



if __name__ == "__main__":
    wiki_scraper()