from django.db import models

class AuthKey(models.Model):
    text = models.CharField(max_length=200)

class ImageUpload(models.Model):
    name = models.CharField(max_length=200, primary_key=True)
    uploaded_file = models.ImageField(upload_to='images') 

class Tag(models.Model):
    title = models.CharField(max_length=200, primary_key=True)

class Page(models.Model):
    name = models.CharField(max_length=200, primary_key=True)
    guid = models.CharField(max_length=200, blank = True, null = True)
    title = models.CharField(max_length=200, blank = True, null = True)
    source = models.CharField(max_length=500, blank = True, null = True)
    url = models.CharField(max_length=500)
    note_updated = models.DateTimeField(blank = True, null = True)
    tags = models.ManyToManyField(Tag, blank = True)
    public = models.BooleanField(default=False)

    def build_page_dict(self):
        page_dict = {}
        page_dict['url'] = self.url
        page_dict['source'] = self.source
        page_dict['title'] = self.title
        page_dict['name'] = self.name
        page_dict['public'] = self.public
        tags = ''
        for tag in self.tags.all():
            tags = tags + tag.title + ', '
        page_dict['tags'] = tags
        return page_dict

    def set_tags(self, tags):
        old_tag_list = list(self.tags.all())
        self.tags.clear()
        for tag in tags:
            t = Tag.objects.get_or_create(title=tag)
            t[0].save()
            if t[0].title:
                self.tags.add(t[0])
            self.save()
        for tag in old_tag_list:
            if not len(tag.page_set.all()):
                tag.delete()
        return self               
