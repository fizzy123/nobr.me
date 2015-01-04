from django.core.management.base import BaseCommand, CommandError
from general.functions import breetz_tweets

class Command(BaseCommand):
    help = 'tweet breetz'

    def handle(self, *args, **options):
        breetz_tweets()
