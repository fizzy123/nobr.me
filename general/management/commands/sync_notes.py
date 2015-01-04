from django.core.management.base import BaseCommand, CommandError
from general.functions import sync_notes

class Command(BaseCommand):
    help = 'syncs notes'

    def handle(self, *args, **options):
        sync_notes()
