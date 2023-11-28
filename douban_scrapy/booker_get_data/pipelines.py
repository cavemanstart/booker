# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
import requests
from bson import binary
from pymongo import MongoClient


class BookerGetDataPipeline:
    dbClient = MongoClient("mongodb://39.103.210.93:27017/")
    db = dbClient["booker"]
    def get_item_value(self,item, key):
        try:
            value = item[key]
        except KeyError:
            return  None
        return value

    def process_item(self, item, spider):
        # save data into database
        book_image_url = item['book_image_url']
        if str(book_image_url).endswith(".jpg"):
            headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36'}
            ret = requests.get(book_image_url, stream=True, timeout=None, headers=headers)
            print(ret.status_code)
            print("------------------")
            if ret.status_code == 200:
                book_image = ret.content
            else:
                book_image = None
        else:
            book_image = None

        book_misc = {
            'id':self.get_item_value(item,"book_id"),
            'detail_url':self.get_item_value(item, 'book_detail_url'),
            'image_url':book_image_url
        }

        book_data = {
            'id':self.get_item_value(item,"book_id"),
            'title':self.get_item_value(item,"book_title"),
            "subtitle":self.get_item_value(item,"book_subtitle"),
            "author":self.get_item_value(item,"book_author"),
            "publisher":self.get_item_value(item,"book_publisher"),
            "publishTime":self.get_item_value(item,"book_publish_time"),
            "pageNum": self.get_item_value(item,"book_page_num") if self.get_item_value(item,"book_page_num") else "0",
            "price":self.get_item_value(item,"book_price"),
            "initDegree":float(self.get_item_value(item,"book_rating") if self.get_item_value(item,"book_rating") else 0)*float(self.get_item_value(item,"book_rating_num") if self.get_item_value(item,"book_rating_num") else 0),
            "image": binary.Binary(book_image) if book_image else None,
            "brief":self.get_item_value(item,"book_brief"),
            "tags":self.get_item_value(item,"book_tags")
        }


        if not self.db.Books.find_one({"id":self.get_item_value(item,"book_id")}):
            self.db.Books.insert(book_data)
            self.db.BooksMisc.insert(book_misc)

        return item
