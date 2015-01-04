from django.conf.urls import patterns, url

from general import views

urlpatterns = patterns('general.views',
    url(r'^$', 'index', name='index'),
    url(r'^page/(?P<name>[^ \t\n\r\f\v/]+)/$', 'page', name='page'),
    url(r'^url/(?P<name>[^ \t\n\r\f\v/]+)/$', 'url', name='url'),
    url(r'^tag/(?P<name>[^ \t\n\r\f\v/]+)/$', 'tag', name='tag'),
    url(r'^edit/(?P<name>[^ \t\n\r\f\v/]+)/$', 'edit', name='edit'),
    url(r'^delete/(?P<name>[^ \t\n\r\f\v/]+)/$', 'delete', name='delete'),
    url(r'^admin/$', 'login_view', name='login'),
    url(r'^rando/$', 'rando', name='rando'),
    url(r'^about/$', 'about', name='about'),
    url(r'^logout/$', 'logout', name='logout'),
    url(r'^upload/$', 'upload', name='upload')
) 
