from evernote.api.client import EvernoteClient

from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.shortcuts import render, render_to_response
from django.contrib.auth import authenticate, login, logout

from general.models import AuthKey, Page, Tag
from general.functions import rand_str_gen, handle_uploaded_file
from general.forms import UploadFileForm

import oauth2 as oauth

import pdb, os, random, re, json

directory = '/srv/nobelyoo/general/templates/general/'
dev_token = "S=s107:U=baed27:E=1505f5da70f:C=14907ac78c0:P=1cd:A=en-devtoken:V=2:H=94e4793a0fee282d836903dcb3525557"

def index(request):
    f = open('/srv/nobelyoo/static/tweets.txt', 'r')
    tweets = f.read()
    tweets = tweets.split(' ')
    indexes = [i for i, x in enumerate(tweets) if x == '###']
    word = tweets[random.choice(indexes) + 1]
    quote = word 
    indexes = [i for i, x in enumerate(tweets) if x == word]
    word = tweets[random.choice(indexes) + 1]
    while word != '###':
        quote = quote + ' ' + word
        indexes = [i for i, x in enumerate(tweets) if x == word]
        word = tweets[random.choice(indexes) + 1]

    pages = list(Page.objects.all().filter(public=True).order_by('?')[0:59])
    pages.append(Page.objects.get(name='about'))
    page_dicts = []
    for page in pages:
        page_dicts.append(page.build_page_dict())
    return render(request, 'general/index.html', {'quote':quote, 'pages':json.dumps(page_dicts)})

def about(request):
    return render(request, 'general/about.html', {})

def tag(request, name=None):
    if name:
        page = Page.objects.filter(tags__title=name).order_by('?')[0]
        return HttpResponseRedirect(page.url)
    else:
        return HttpResponseRedirect(reverse('general:index'))
        
def rando(request):
    include_all = request.GET.has_key('all')
    if include_all:
        page = Page.objects.all().order_by('?')[0]
    else:
        page = Page.objects.all().filter(public=True).order_by('?')[0]
    return HttpResponseRedirect(page.url)

def page(request, name=None):
    if name:
        return render(request, 'general/%s.html' % name);
    else:
        return HttpResponseRedirect(reverse('general:index'))

def url(request, name=None):
    if name:
        page = Page.objects.get(name=name)
        return HttpResponseRedirect(page.source)
    else:
        return HttpResponseRedirect(reverse('general:index'))

def edit(request, name='Intro'):
    if request.META['REQUEST_METHOD'] == 'GET':
        if request.user.is_authenticated():
            p = Page.objects.get_or_create(name=name)[0]
            context = {'page': p.build_page_dict()}
            return render(request, 'general/edit.html', context)
        else:
            raise Http404
    elif request.META['REQUEST_METHOD'] == 'POST':

        p, created = Page.objects.get_or_create(name=name)
        p.name = request.POST['name']
        p.url = request.POST['url']
        if request.POST.has_key('public'):
            p.public = True
        else:
            p.public = False
        p.set_tags(request.POST['tags'].split(', '))
        uri_components = p.url.split('/')
        if uri_components[-2] == 'page':
            uri_components[-1] = request.POST['name']
            p.url = '/'.join(uri_components)
        p.save()
        for filename in os.listdir(directory):
            if filename == '%s.html' % name:
                os.rename(directory + filename, ('%s%s.html' % (directory, request.POST['name'])))

        return HttpResponseRedirect(p.url)

def delete(request, name):
    if request.META['REQUEST_METHOD'] == 'POST':
        p = Page.objects.get(name=name)
        if len(p.name) == 36 and len(p.name.split('-')) == 5:
            client = EvernoteClient(token=dev_token, sandbox=False)
            note_store = client.get_note_store()
            note_store.deleteNote(dev_token, name);
        p.delete()
        uri_components = p.url.split('/')
        if uri_components[-2] == 'page':
            os.remove(directory + name +'.html')
        return HttpResponseRedirect(reverse('general:rando'))
    else:
        raise Http404

def login_view(request):
    if request.META['REQUEST_METHOD'] == 'GET':
        logout(request)
        key = AuthKey.objects.all()
        if key:
            key = key[0]
        else:
            key = AuthKey.objects.create()
        if key.text != '':
            key.text = ''
        key.text=rand_str_gen(200)
        key.save()
        return render(request, 'general/login.html', {})
    elif request.META['REQUEST_METHOD'] == 'POST':
        key = AuthKey.objects.all()[0]
        user = authenticate(username=request.POST['username'], password=request.POST['password'])
        if key.text == request.POST['text'].replace('\n','') and user:
            login(request, user)
            return HttpResponseRedirect(reverse('feed:display'))
        else:
            return HttpResponseRedirect(reverse('general:login'))

def upload(request):
    if request.session['logged_in'] if request.session.has_key('logged_in') else False:
        if request.META['REQUEST_METHOD'] == 'GET':
            form = UploadFileForm()
            return render(request, 'general/upload.html', {'form': form})
        elif request.META['REQUEST_METHOD'] == 'POST':
            form = UploadFileForm(request.POST, request.FILES)
            if form.is_valid():
                handle_uploaded_file(request.FILES['file'], request.POST['title'])
                return HttpResponseRedirect(reverse('general:index'))
            else:
                print form.errors
            return render(request, 'general/upload.html', {})
    else:
        raise Http404
   
