# line-up-news
Download zip files from web using [Ruby](https://www.ruby-lang.org/en/) and store xml data in [Redis](http://redis.io).

#####Steps for Getting Started
1. Install the gems from the command line.

	* [gem install nokogiri](https://github.com/sparklemotion/nokogiri)
	* [gem install zip-zip](https://github.com/orien/zip-zip)
	* [gem install redis](https://github.com/redis/redis-rb)
	* [gem install xml/to/json](https://github.com/digitalheir/ruby-xml-to-json)

2. Do **$ruby zipfiles.rb**

	'/tmp' folder is created for downloaded zip files from url and extracted files. Then stores xml data as json in [Redis](http://redis.io).

