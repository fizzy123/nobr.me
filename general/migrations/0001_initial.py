# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='AuthKey',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('text', models.CharField(max_length=200)),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='ImageUpload',
            fields=[
                ('name', models.CharField(max_length=200, serialize=False, primary_key=True)),
                ('uploaded_file', models.ImageField(upload_to=b'images')),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Page',
            fields=[
                ('name', models.CharField(max_length=200, serialize=False, primary_key=True)),
                ('guid', models.CharField(max_length=200, null=True, blank=True)),
                ('title', models.CharField(max_length=200, null=True, blank=True)),
                ('source', models.CharField(max_length=500, null=True, blank=True)),
                ('url', models.CharField(max_length=500)),
                ('note_updated', models.DateTimeField(null=True, blank=True)),
                ('public', models.BooleanField(default=False)),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Tag',
            fields=[
                ('title', models.CharField(max_length=200, serialize=False, primary_key=True)),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.AddField(
            model_name='page',
            name='tags',
            field=models.ManyToManyField(to='general.Tag', null=True, blank=True),
            preserve_default=True,
        ),
    ]
