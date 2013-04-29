#!/usr/local/bin/ruby
require 'rubygems'
require 'mechanize'

#Change url and run with watch/cron
#CRON example, every minute:
# * * * * * /usr/local/bin/ruby {PATH_TO_SCRIPT}/scraper.rb >> /tmp/scraper.log

#Example url, apartments for rent in Linköping
searchurl = "http://www.blocket.se/bostad/uthyres/ostergotland/linkoping"

def scrape(url)
    latest_path = '/tmp/latest'
    `touch #{latest_path}`
    latest_file = File.new(latest_path, 'r')
    latest_url = latest_file.gets
    latest_url = latest_url ? latest_url.chomp : nil
    agent = Mechanize.new
    new_listings_url = []
    top_listings = agent.get(url).search("//div[@id='item_list']//div[@class='desc']/a")
    top_listings.each do |listing|
        listing_url = listing.attributes['href'].content
        if listing_url == latest_url
            break
        end
        new_listings_url << listing_url
    end
    if new_listings_url.first
        #New listings!
        latest_file = File.new(latest_path, 'w')
        latest_file.puts(new_listings_url.first)
        new_listings_url.each do |url|
            puts "Found new listing! url: #{url}"
            #Should open in correct browser
            `open #{url}`
            #TODO Growl support?
        end
    end
end

scrape(searchurl)
