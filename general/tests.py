from django.test import TestCase
from django.utils import timezone
from django.core.urlresolvers import reverse

from general.models import AuthKey, ImageUpload
from blog.models import Post

from general.functions import rand_str_gen, parse_post_content, parse_wiki_title, parse_wiki_link

import pdb, logging

def authenticate(self):
    self.client.get(reverse('general:login'))
    a = AuthKey.objects.all()[0]
    self.client.post(reverse('general:login'),{'text': a.text})

class GeneralViewTests(TestCase):
    def test_index_view(self):
        """
        A request to index view should be redirected to the blog index view
        """
        response = self.client.get(reverse('general:index'))
        self.assertEqual(response['location'], 'http://testserver/blog/')

    def test_login_view(self):
        """
        Once the login view is loaded, the AuthKey should no longer be empty

        If the AuthKey is sent to the same URL through a POST method, a user
        session should be created.
        """
        AuthKey.objects.create(text='')
        self.client.get(reverse('general:login'))
        a = AuthKey.objects.all()[0]
        self.assertNotEqual(a.text, '')
        self.assertEqual(len(a.text), 200)
        self.client.post(reverse('general:login'), {'text': a.text})
        self.assertEqual(self.client.session['logged_in'], True)
        response = self.client.get(reverse('general:logout'))
        self.assertEqual(self.client.session['logged_in'], False)
        self.assertEqual(response['location'], 'http://testserver/')

    def test_upload_view(self):
        """
        The upload view should allow files to be uploaded
        """
        authenticate(self)
        with open('test.txt') as fp:
            response = self.client.post('/upload/', {'title': 'test.txt', 'file': fp})
            self.assertEqual(response.status_code, 302)
            upload = ImageUpload.objects.all()[0]
            self.assertEqual(upload.name, 'test.txt')

class GeneralMethodTests(TestCase):
    def test_rand_str_gen(self):
        """
        rand_str_size should return a string of length @size
        """
        str = rand_str_gen(20)
        self.assertEqual(len(str), 20)
        str = rand_str_gen(40)
        self.assertEqual(len(str), 40)

    def test_parse_post_content_line_breaks(self):
        """
        parse_post_content should replace all line breaks
        """
        test_str1 = "Hey \r\n This \r\n should \r\n\r\n be \n\r\ be"
        str1 = parse_post_content(test_str1, 'display')
        self.assertEqual(str1, "Hey <br/> This <br/> should <br/><br/> be \n\r\ be")
        str2 = parse_post_content(str1, 'edit')
        self.assertEqual(str2, test_str1)

    def test_parse_post_content_wiki_links(self):
        """
        parse_post_content should replace all wiki links
        """
        test_str1 = "this thing [[link|link text]] [[article]] and [[Two Fingers|Crazy muthafucka]] is cool dude [[Coheed and Combria (band)|wtf]] then [[Hello World]]"
        str1 = parse_post_content(test_str1, 'display')
        self.assertEqual(str1, "this thing <a href='/wiki/link/'>link text</a> <a href='/wiki/article/'>article</a> and <a href='/wiki/Two_Fingers/'>Crazy muthafucka</a> is cool dude <a href='/wiki/Coheed_and_Combria_(band)/'>wtf</a> then <a href='/wiki/Hello_World/'>Hello World</a>")
        str2 = parse_post_content(str1, 'edit')
        self.assertEqual(str2, test_str1)

        test_str3 = "Currently, I am undergraduate student in [[Physics]].<br/><br/>[[Likes|here are some things I like]]"
        str3 = parse_post_content(test_str3, 'display')
        self.assertEqual(str3, "Currently, I am undergraduate student in <a href='/wiki/Physics/'>Physics</a>.<br/><br/><a href='/wiki/Likes/'>here are some things I like</a>")

    def test_parse_post_content_links(self):
        """
        parse_post_content should replace all links
        """
        test_str1 = "what what [www.google.com,whatlinks] and [www.yahoo.com]"
        str1 = parse_post_content(test_str1, 'display')
        self.assertEqual(str1, "what what <a href='www.google.com'>whatlinks</a> and <a href='www.yahoo.com'>www.yahoo.com</a>")
        str2 = parse_post_content(str1, 'edit')
        self.assertEqual(str2, test_str1)

    def test_parse_post_content_images(self):
        """
        parse_post_content should replace images
        """
        test_str1 = "what what [[dumb.jpg|400]], [[hello.gif]], [[wtf.bmp]] and [[geez.png]]"
        str1 = parse_post_content(test_str1,'display')
        self.assertEqual(str1, "what what <img src='/media/images/dumb.jpg' width='400'>, <img src='/media/images/hello.gif'>, <img src='/media/images/wtf.bmp'> and <img src='/media/images/geez.png'>")
        str2 = parse_post_content(str1,'edit')
        self.assertEqual(str2,test_str1)

    def test_parse_wiki_titles_for_space(self):
        test_str1 = "Embedded_Systems"

        str1 = parse_wiki_title(test_str1)
        self.assertEqual(str1, "Embedded Systems")
        
    def test_parse_wiki_title_for_period(self):
        test_str1 = "nobel_dot_com"

        str1 = parse_wiki_title(test_str1)
        self.assertEqual(str1, "Nobel.com")

    def test_parse_wiki_link_edit(self):
        str1 = parse_wiki_link("Super_trooper", "edit")
        self.assertEqual(str1, "Super trooper")
    
    def test_parse_wiki_link_display(self):
        str1 = parse_wiki_link("Super trooper", "display")
        self.assertEqual(str1, "Super_trooper")
        
