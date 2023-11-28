import scrapy
import bs4
from ..items import BookItem


class DoubanSpider(scrapy.Spider):
    name = 'douban'
    allowed_domains = ['book.douban.com']
    start_urls = list()

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        with open("./tags3") as tags_file:
            for line in tags_file.readlines():
                line = line.strip()
                if line[0]!='#':
                    self.start_urls.extend(['https://book.douban.com/tag/'+line+'?start='+str(index)+'&type=T' for index in range(0,1000,20)])

    def parse(self, response, **kwargs):
        print(response.request.headers['User-Agent'])
        soup = bs4.BeautifulSoup(response.text, "lxml")
        books = soup.find_all('li', attrs={'class':'subject-item'})
        for book in books:
            item = BookItem()
            item['book_title'] = book.find_all('a')[1]["title"]
            detail_url = book.find('a', attrs={"class":"nbg"})["href"]
            item['book_detail_url'] = detail_url
            yield scrapy.Request(detail_url,callback=self.parse_detail,meta={'item':item})

    def parse_detail(self, response):
        item = response.meta['item']
        soup = bs4.BeautifulSoup(response.text, "lxml")

        book_pic_info = soup.find('div', attrs={"id":"mainpic"})
        item['book_image_url'] = book_pic_info.find('img')["src"]

        book_basic_info = soup.find('div', attrs={"id":"info"})

        book_basic_strs = book_basic_info.getText().split()

        #extract info from str list
        i = 0
        while i < len(book_basic_strs):
            if ':' in book_basic_strs[i]:
                data = ""
                type_index = i
                for j in range(i+1, len(book_basic_strs)+1):
                    i = j
                    if i>= len(book_basic_strs):
                        break
                    if ':' in book_basic_strs[j]:
                        break
                    if '作者' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_author'] = data
                    if '副标题' in book_basic_strs[type_index]:
                        data+= book_basic_strs[j]
                        item['book_subtitle'] = data
                    if '出版社' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_publisher'] = data
                    if '出版年' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_publish_time'] = data
                    if '页数' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_page_num'] = data
                    if '定价' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_price'] = data
                    if 'ISBN' in book_basic_strs[type_index]:
                        data += book_basic_strs[j]
                        item['book_id'] = data


        book_rating_info = soup.find('div', attrs={"class":"rating_wrap"})
        book_rating= book_rating_info.find('strong').string.strip()
        item['book_rating'] = book_rating if len(book_rating)!=0 else 0
        vote_soup = item['book_rating_num'] = book_rating_info.find('span', attrs={'property':'v:votes'})
        if vote_soup:
            item['book_rating_num'] = vote_soup.string.strip()
        else:
            item['book_rating_num'] = 0

        book_brief_hidden = soup.find('span', attrs={"class":"all"})
        if book_brief_hidden is not None:
            book_brief_hidden_soup = book_brief_hidden.find('div', attrs={'class': "intro"})
            if book_brief_hidden_soup:
                book_brief_text = book_brief_hidden_soup.find_all('p')
                book_brief_show = self.extract_brief(book_brief_text)
            else:
                book_brief_show = []
        else:
            book_brief_show_soup = soup.find('div', attrs={'class': "intro"})
            if book_brief_show_soup:
                book_brief_text = book_brief_show_soup.find_all('p')
                book_brief_show = self.extract_brief(book_brief_text)
            else:
                book_brief_show = []

        item['book_brief'] = book_brief_show

        item['book_tags'] = list()
        tags_area = soup.find_all('a',attrs={"class":"tag"})
        for elem in tags_area:
            item['book_tags'].append(elem.string)

        yield item

    def extract_brief(self, text):
        text_show = list()
        for paragraph in text:
            text_show.append(paragraph.getText().replace(u'\xa0', u' ').replace('\t'," ").replace(u"\u3000"," ").replace(u"\xe4"," ").strip())
        return text_show




