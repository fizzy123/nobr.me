from django.core.management.base import BaseCommand, CommandError
from general.functions import nobr_bot

class Command(BaseCommand):
    help = 'tweet breetz'

    def handle(self, *args, **options):
        nobr_bot()
