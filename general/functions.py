import string, random, re, pdb, json, pytz, urllib
from datetime import datetime
from time import mktime
import oauth2 as oauth

from django.core.urlresolvers import reverse
from django.http import HttpResponse

from general.models import ImageUpload

class DefaultEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return int(mktime(obj.timetuple()))

        return json.JSONEncoder.default(self, obj)

def json_response(context):
    return HttpResponse(json.dumps(context, cls = DefaultEncoder), content_type="application/json")

def rand_str_gen(size):
    return ''.join(random.choice(string.ascii_uppercase + string.digits + string.ascii_lowercase) for x in range(size))

def parse_content(raw_content,mode):
    return parse_post_content(raw_content,mode)

def parse_post_content(raw_content, mode):
    if mode=='display':

        # Convert Newlines
        content = raw_content.replace('\r\n', '<br/>')

        #Pull out sections that shouldn't be formatted
        escaped_text = []
        m =  re.search(r"/\*(?P<escape>.*)\*/", content)
        while m:
            content = content.replace("/*"+ m.group('escape')+"*/", "*/"+str(len(escaped_text))+"/*")
            escaped_text.append(m.group('escape'))
            m =  re.search(r"/\*(?P<escape>.*)\*/", content)

        #Convert Images
        m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|PNG|bmp|BMP))\|(?P<width>[0-9]+?)\]\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<img src='/media/images/",
                      m.group('link'),
                      "' width='", 
                      m.group('width'),
                      "'>",
                      content[m.end():]])
            m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|PNG|bmp|BMP))\|(?P<width>[0-9]+?)\]\]", content)

        m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|PNG|bmp|BMP))\]\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<img src='/media/images/",
                      m.group('link'),
                      "'>",
                      content[m.end():]])
            m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|PNG|bmp|BMP))\]\]", content)

        # Convert node links
        m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?)\|(?P<link_text>[^\t\n\r\f\v\[\]]+?)\]\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<a class='link' href='/",
                      m.group('link').replace(' ', '_'),
                      "'>", 
                      m.group('link_text'),
                      "</a>",
                      content[m.end():]])
            m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?)\|(?P<link_text>[^\t\n\r\f\v\[\]]+?)\]\]", content)
        m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?)\]\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<a class='link' href='/",
                      m.group('link').replace(' ', '_'),
                      "'>",
                      m.group('link'),
                      "</a>",
                      content[m.end():]])
            m = re.search(r"\[\[(?P<link>[^\t\n\r\f\v\[\]]+?)\]\]", content)
    
        # Convert links
        m = re.search(r"\[(?P<link>[^ \t\n\r\f\v\[\]]+?),(?P<link_text>[^\t\n\r\f\v\[\]]+?)\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<a href='",
                      m.group('link'),
                      "'>", 
                      m.group('link_text'),
                      "</a>",
                      content[m.end():]])
            m = re.search(r"\[(?P<link>[^ \t\n\r\f\v\[\]]+?),(?P<link_text>[^\t\n\r\f\v\[\]]+?)\]", content)
        m = re.search(r"\[(?P<link>[^ \t\n\r\f\v\[\]]+?)\]", content)
        while m:
            content = ''.join([content[:m.start()],
                      "<a href='",
                      m.group('link'),
                      "'>",
                      m.group('link'),
                      "</a>",
                      content[m.end():]])
            m = re.search(r"\[(?P<link>[^ \t\n\r\f\v\[\]]+?)\]", content)

        #Put sections back in after formatting
        m =  re.search(r"\*/(?P<escape>\d+)/\*", content)
        while m:
            content = content.replace("*/"+m.group('escape')+"/*", escaped_text[int(m.group('escape'))])
            m =  re.search(r"\*/(?P<escape>\d+)/\*", content)
            
    elif mode=='edit':

        # Convert Newlines

        content = raw_content.replace('<br/>', '\r\n')
        
        # Convert images
        m = re.search(r"<img src='/media/images/(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|bmp|BMP))' width='(?P<width>[0-9]+?)'>", content)
        while m:
            content = ''.join([content[:m.start()],
                      "[[", m.group('link'), "|",
                      m.group('width'),"]]",
                      content[m.end():]])
            m = re.search(r"<img src='/media/images/(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|bmp|BMP))' width='(?P<width>[0-9]+?)'>", content)
   
        m = re.search(r"<img src='/media/images/(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|bmp|BMP))'>", content)
        while m:
            content = ''.join([content[:m.start()],
                      "[[", m.group('link'), "]]",
                      content[m.end():]])
            m = re.search(r"<img src='/media/images/(?P<link>[^\t\n\r\f\v\[\]]+?\.(jpg|JPG|gif|GIF|png|bmp|BMP))'>", content)
        
        # Convert wiki links
        m = re.search(r"<a class='link' href='/(?P<link>[^\t\n\r\f\v]+?)'>(?P<link_text>[^\t\n\r\f\v]+?)</a>", content)
        while m:
            if parse_wiki_link(m.group('link'),mode) == m.group('link_text'):
                content = ''.join([content[:m.start()], 
                          "[[", parse_wiki_link(m.group('link').replace('_', ' '), mode), "]]",
                          content[m.end():]])
            else:
                content = ''.join([content[:m.start()],
                          "[[", parse_wiki_link(m.group('link').replace('_', ''), mode), "|", m.group('link_text'), "]]",
                          content[m.end():]])
            m = re.search(r"<a class='link' href='/(?P<link>[^\t\n\r\f\v]+?)'>(?P<link_text>[^\t\n\r\f\v]+?)</a>", content)
            
        # Convert links
        m = re.search(r"<a href='(?P<link>[^\t\n\r\f\v]+?)'>(?P<link_text>[^\t\n\r\f\v]+?)</a>", content)
        while m:
            if m.group('link') == m.group('link_text'):
                content = ''.join([content[:m.start()], 
                          "[", m.group('link_text'), "]",
                          content[m.end():]])
            else:
                content = ''.join([content[:m.start()],
                          "[", m.group('link'), ",", m.group('link_text'), "]",
                          content[m.end():]])
            m = re.search(r"<a href='(?P<link>[^\t\n\r\f\v]+?)'>(?P<link_text>[^\t\n\r\f\v]+?)</a>", content)
            
    return content

def parse_wiki_title(title):
    title = title.replace('_dot_', '.')
    title = title.replace('_',' ')
    title = string.capwords(title)
    return title

def parse_wiki_link(link, mode):
    if mode == 'edit':
        link =  link.replace('_',' ')
    elif mode == 'display':
        link = link.replace(' ','_')
    return link

def handle_uploaded_file(uploaded_file, name):
    upload = ImageUpload.objects.get_or_create(uploaded_file = uploaded_file, name=name)
    upload[0].save()


from evernote.api.client import EvernoteClient
from evernote.edam.notestore.ttypes import NoteFilter, NotesMetadataResultSpec
from evernote.edam.type.ttypes import NoteSortOrder

from general.models import Page

def sync_notes():
    dev_token = "S=s107:U=baed27:E=1505f5da70f:C=14907ac78c0:P=1cd:A=en-devtoken:V=2:H=94e4793a0fee282d836903dcb3525557"
    client = EvernoteClient(token=dev_token, sandbox=False)
    note_store = client.get_note_store()
    offset = 0

    note_filter = NoteFilter(order=NoteSortOrder.UPDATED)
    result_spec = NotesMetadataResultSpec(includeTitle=True, includeAttributes=True, includeUpdated=True)
    result_list = note_store.findNotesMetadata(dev_token, note_filter, 0, 100, result_spec)
    total = result_list.totalNotes

    while offset < total:
        for note in result_list.notes:
            if not note.deleted:
                page = Page.objects.filter(name=note.guid)
                print note.guid
                if not page:
                    page = Page(name = note.guid, url = 'http://www.nobr.me/page/%s' % note.guid )
                    page.save()

                    page.set_tags(note_store.getNoteTagNames(dev_token, note.guid))
                    f = open('/srv/nobelyoo/general/templates/general/%s.html' % note.guid, 'w')
                    if re.match(r'.(?:jpg|gif|png)',note.attributes.sourceUrl):
                        f.write( '{% extends "base_template.html" %} \n\n{% block content %}\n<img src="'+note.attributes.sourceURL+'"/>\n{% endblock %}')
                    else:
                        f.write( '{% extends "base_template.html" %} \n\n{% block content %}\n'+note_store.getNoteContent(dev_token, note.guid)+'\n'+note.attributes.sourceURL+'\n{% endblock %}')
                    f.close()
                else:
                    page = page[0]
                page.guid = note.guid
                page.note_updated = pytz.utc.localize(datetime.fromtimestamp(note.updated/1000.0))
                page.title = re.sub(r'[^\x00-\x7F]+',' ',note.title)
                page.source = note.attributes.sourceURL
                print note.guid
                page.save()
        offset = offset + 100
        result_list = note_store.findNotesMetadata(dev_token, note_filter, offset, 100, result_spec)

def oauth_req(url, key, secret, http_method="GET", post_body='', http_headers=''):
    consumer = oauth.Consumer(key='sfWUDF0mHPit4lBWW1vHff9LA', secret='Krmbxk0UdbQsMY5zLjSKGwatTlBsVegIcM3psZmtCx8EFZMgqS')
    token = oauth.Token(key=key, secret=secret)
    client = oauth.Client(consumer, token)
    return client.request( url, method=http_method, body=post_body, headers=http_headers)[1]

def breetz_oauth_req(url, key, secret, http_method="GET", post_body='', http_headers=''):
    consumer = oauth.Consumer(key='qeqeZ6p5v6mnW95nMSIHgs5Wv', secret='dEpB3M8PfCUnOMiliJoXxMRfqQLZBE4JGtTLF8AlOD04ECMPAm')
    token = oauth.Token(key=key, secret=secret)
    client = oauth.Client(consumer, token)
    return client.request( url, method=http_method, body=post_body, headers=http_headers)[1]


def nobr_bot():
    text = []
    max_id = 0
    home_timeline = oauth_req( 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=xXxN0831xXx&count=200', '544975086-kLoThdRZjbburU8x7yUIhPhdd2Gcdq0uqMNYDdyO', 'kNScrJZZXtWWF1kohKBf6Rul3LcN9A9dtoEVidBobVOmy' )
    home_timeline = json.loads(home_timeline)
    while len(home_timeline) != 0:
        for tweet in home_timeline:
            if not re.search(r'https?:\/\/.*[\r\n]*',tweet['text']):
                tweet['text'] = re.sub(r'RT ', '', tweet['text'], flags=re.MULTILINE)
                tweet['text'] = re.sub(r'@(\S)* ', '', tweet['text'], flags=re.MULTILINE)
                text = text + tweet['text'].split(' ') + ['###']
        max_id = str(home_timeline[-1]['id'] - 1)
        home_timeline = oauth_req( 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=xXxN0831xXx&count=200&max_id=' + max_id, '544975086-kLoThdRZjbburU8x7yUIhPhdd2Gcdq0uqMNYDdyO', 'kNScrJZZXtWWF1kohKBf6Rul3LcN9A9dtoEVidBobVOmy' )
        home_timeline = json.loads(home_timeline)
    f = open('/srv/nobelyoo/static/tweets.txt', 'w')
    f.write(re.sub(r'[^\x00-\x7F]+',' ',' '.join(text)))
    f.close()


def breetz_oauth_req(url, key, secret, http_method="GET", post_body='', http_headers=''):
    consumer = oauth.Consumer(key='qeqeZ6p5v6mnW95nMSIHgs5Wv', secret='dEpB3M8PfCUnOMiliJoXxMRfqQLZBE4JGtTLF8AlOD04ECMPAm')
    token = oauth.Token(key=key, secret=secret)
    client = oauth.Client(consumer, token)
    return client.request( url, method=http_method, body=post_body, headers=http_headers)[1]

def breetz_bot():
    text = []
    max_id = 0
    home_timeline = oauth_req( 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=BreetzTweetz&count=200&exclude_replies=true', '544975086-kLoThdRZjbburU8x7yUIhPhdd2Gcdq0uqMNYDdyO', 'kNScrJZZXtWWF1kohKBf6Rul3LcN9A9dtoEVidBobVOmy' )
    home_timeline = json.loads(home_timeline)
    while len(home_timeline) != 0:
        for tweet in home_timeline:
            if not re.search(r'https?:\/\/.*[\r\n]*',tweet['text']):
                tweet['text'] = re.sub(r'RT ', '', tweet['text'], flags=re.MULTILINE)
                tweet['text'] = re.sub(r'@(\S)* ', '', tweet['text'], flags=re.MULTILINE)
                text = text + tweet['text'].split(' ') + ['###']
        max_id = str(home_timeline[-1]['id'] - 1)
        home_timeline = oauth_req( 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=BreetzTweetz&count=200&exclude_replies=true&max_id=' + max_id, '544975086-kLoThdRZjbburU8x7yUIhPhdd2Gcdq0uqMNYDdyO', 'kNScrJZZXtWWF1kohKBf6Rul3LcN9A9dtoEVidBobVOmy' )
        home_timeline = json.loads(home_timeline)
    f = open('/srv/nobelyoo/static/breetz.txt', 'w')
    f.write(re.sub(r'[^\x00-\x7F]+',' ',' '.join(text)))
    f.close()

def breetz_tweets():
    f = open('/srv/nobelyoo/static/breetz.txt', 'r')
    tweets = f.read()
    tweets = tweets.split(' ')
    first = True
    indexes = [i for i, x in enumerate(tweets) if x == '###']
    word = tweets[random.choice(indexes) + 1]
    quote = word
    indexes = [i for i, x in enumerate(tweets) if x == word]
    word = tweets[random.choice(indexes) + 1]

    while word != '###':
        quote = quote + ' ' + word
        indexes = [i for i, x in enumerate(tweets) if x == word]
        word = tweets[random.choice(indexes) + 1]
    #print quote
    print breetz_oauth_req('https://api.twitter.com/1.1/statuses/update.json','2887934017-7V8PiFbKxiKcXecncvoF4NMPVoxlx5LgEXQBVZW', 'vfrFWuPyrvbMr0roDD5SVPyhv6OQlF0TLJbQ9SDNmz2xh',"POST",urllib.urlencode({'status':quote}))

