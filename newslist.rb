require 'redis'

class NewsList

	REDIS_KEY = 'NEWS_XML'
	NUM_NEWS = 20
	TRIM_THRESHOLD = 500

	def initialize
		@db = Redis.new
		@trim_count = 0	
	end


	def push(data)
		#list - NEWS_XML 
		#p "inside push "
		@db.rpush(REDIS_KEY, data)
		p "length of list stored at key :::"+(@db.llen(REDIS_KEY)).to_s
		@trim_count += 1
		if(@trim_count > TRIM_THRESHOLD)
			#p @trim_count.to_s+" trim_count ****************  Before---"
			@db.ltrim(REDIS_KEY, 0, NUM_NEWS)
			@trim_count =0
			#p @trim_count.to_s+" trim_count ****************   After ------"
		end
	end


end





