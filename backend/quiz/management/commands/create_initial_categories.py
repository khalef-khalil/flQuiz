from django.core.management.base import BaseCommand
from quiz.models import Category

class Command(BaseCommand):
    help = 'Creates initial quiz categories'

    def handle(self, *args, **kwargs):
        categories = [
            {
                'name': 'Mathematics',
                'description': 'Test your knowledge in mathematics, from basic arithmetic to advanced calculus.'
            },
            {
                'name': 'Physics',
                'description': 'Explore the fundamental laws that govern the universe.'
            },
            {
                'name': 'Geography',
                'description': 'Learn about countries, cultures, and natural phenomena around the world.'
            }
        ]

        for category_data in categories:
            category, created = Category.objects.get_or_create(
                name=category_data['name'],
                defaults={'description': category_data['description']}
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created category "{category.name}"'))
            else:
                self.stdout.write(self.style.WARNING(f'Category "{category.name}" already exists')) 