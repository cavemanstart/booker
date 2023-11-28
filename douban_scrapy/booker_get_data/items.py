# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy

class BookItem(scrapy.Item):
    """
    book_id ISBN号

    book_title 标题

    book_subtitle 子标题

    book_author 作者

    book_publisher 出版社

    book_publish_time 出版时间

    book_page_num 页数

    book_price 定价

    book_rating douban评分

    book_rating_num douban评分人数

    book_image_url 图书图片的url

    book_brief 图书简介

    book_tags 图书标签
    """
    book_id = scrapy.Field()
    book_title = scrapy.Field()
    book_subtitle = scrapy.Field()
    book_author = scrapy.Field()
    book_publisher = scrapy.Field()
    book_publish_time = scrapy.Field()
    book_page_num = scrapy.Field()
    book_price = scrapy.Field()
    book_rating = scrapy.Field()
    book_rating_num = scrapy.Field()
    book_image_url = scrapy.Field()
    book_brief = scrapy.Field()
    book_tags = scrapy.Field()

    #util
    book_detail_url = scrapy.Field()

