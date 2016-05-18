# line-up-news
Download zip files from web using Ruby and store xml data in Redis.

###Steps for Getting Started
1. Install the gems from the command line.

	* gem install nokogiri
	* gem install zip-zip
	* gem install redis
	* gem install xml/to/json

2. Do **$ruby zipfiles.rb**

	'/tmp' folder is created for downloaded zip files from url and extracted files. Then stores xml data as json in [Redis](http://redis.io).

