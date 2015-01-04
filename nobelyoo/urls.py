from django.conf.urls import patterns, include, url
from django.conf import settings
from django.conf.urls.static import static


# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
	url(r'^', include('general.urls', namespace='general')),
	url(r'^blog/', include('blog.urls', namespace='blog')),
	url(r'^wiki/', include('wiki.urls', namespace='wiki')),
	url(r'^gif/', include('gif.urls', namespace='gif')),
	url(r'^gif_or_jpeg/', include('gif_or_jpeg.urls', namespace='gif_or_jpeg')),
	url(r'^archives/', include('archives.urls',namespace='archives')),
	url(r'^legacy/', include('legacy.urls',namespace='legacy')),
	url(r'^buzzwords/', include('buzzwords.urls',namespace='buzzwords')),
	url(r'^bestof/', include('bestof.urls',namespace='bestof')),
        url(r'^test/', include('spoton_test.urls',namespace='spoton_test')),
        url(r'^feed/', include('feed.urls', namespace='feed')),
        url(r'^startups/', include('startups.urls', namespace='startups'))
) + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
