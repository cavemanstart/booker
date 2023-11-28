import redis
password = "redis2021"
redis_pool = redis.ConnectionPool(host="172.31.225.73",port=6379,decode_responses=True,password=password)
redis_client = redis.StrictRedis(connection_pool=redis_pool)

