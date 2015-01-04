from django.core.management.base import BaseCommand, CommandError
from general.functions import breetz_bot

class Command(BaseCommand):
    help = 'tweet breetz'

    def handle(self, *args, **options):
        breetz_bot()
