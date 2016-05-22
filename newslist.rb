require 'redis'

class NewsList

	REDIS_KEY = 'NEWS_XML'
	NUM_NEWS = 20
	TRIM_THRESHOLD = 1000

	def initialize
		@db = Redis.new
		@trim_count = 0	
	end


	def push(data)
		#list - NEWS_XML 
		p "inside push "
		# zadd or sadd - dosent store duplicate data
		@db.zadd(REDIS_KEY, @trim_count, data)
		#p "length of sorted list ::::"+(@db.zcard(REDIS_KEY)).to_s
		@trim_count += 1
		#if(@trim_count > TRIM_THRESHOLD)
			#@db.zremrangebyrank(REDIS_KEY, 0, NUM_NEWS)
			#@trim_count = 0
			#p "length of sorted list ::::"+(@db.zcard(REDIS_KEY)).to_s
			#p (@db.zrange(REDIS_KEY, 0, 10, WITHSCORES)).to_s
		#end
	end


end





