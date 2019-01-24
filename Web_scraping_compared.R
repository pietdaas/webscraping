##Test with various ways of web scraping
setwd("/home /piet/R")

##load libs
library(stringr)
library(XML)

##set url to a web page
url <- "http://www.pietdaas.nl"

##function to convert doc to html
storeHTML <- function(doc, name) {
  ##check doc
  if(doc[1] != "") {
    ##parse html
    suppressWarnings(doc <- str_flatten(doc, collapse = ""))
    ##parse doc as html via Python 
    ##html <- BS4$BeautifulSoup(doc, 'lxml')
    html <- htmlParse(doc)
    ##store html
    sink(file = paste0(name, ".html"))
    print(html)
    sink()
  }
}

##1 use wget
doc <- system2('wget', args = c('-e', 'robots=off', '-q', '-O', '-', url), stdout = TRUE, stderr = FALSE) ##most direct way to scrape the web
storeHTML(doc, "wget")

##2 use httr
library(httr)
doc <- GET(url = url)
storeHTML(doc, "httr") ##will produce message: No encoding supplied: defaulting to UTF-8.

##3 use read_html
library(xml2)
doc <- read_html(x = url)
storeHTML(doc, "xml2")

##4 use curl
library(RCurl)
userAgentString <- "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
doc <- getURL(url, ssl.verifyhost = 0L, ssl.verifypeer = 0L, httpheader = c('User-Agent' = userAgentString), .encoding = 'UTF-8')
storeHTML(doc, "Curl")

##5 use headless chrome direct]
doc <- system2('google-chrome', args = c('--headless', '--disable-gpu', '--disable-software-rasterizer', '--dump-dom', url), stdout = TRUE, stderr = FALSE)
storeHTML(doc, "chrome_headless")

##6 with decapitated package
library(decapitated)
doc <- chrome_read_html(url = url, chrome_bin = "/usr/bin/google-chrome")  ##OR "/usr/bin/chromium-browser"
storeHTML(doc, "decap")

##7 with firefox and selenium
##Make sure selenium server is running (java -jar selenium-server-standalone-3.9.1.jar)
library(RSelenium)
eCaps <- list(chromeOptions = list(args = c('--headless', '--disable-gpu', '--window-size=1280,800')))
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444L, browserName = "chrome", extraCapabilities = eCaps)
remDr$open(silent = TRUE)
remDr$navigate(url = url)
doc <- remDr$getPageSource()
storeHTML(doc, "Selenium")

##8 by using Phantomjs (but that is not popular anymore)
##see https://www.datacamp.com/community/tutorials/scraping-javascript-generated-data-with-r for more info
