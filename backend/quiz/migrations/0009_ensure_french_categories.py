from django.db import migrations

def ensure_french_categories(apps, schema_editor):
    User = apps.get_model('auth', 'User')
    Category = apps.get_model('quiz', 'Category')
    
    DEFAULT_CATEGORIES = [
        {
            'name': 'Mathématiques',
            'description': 'Tests de connaissances en mathématiques, de l\'arithmétique au calcul avancé.'
        },
        {
            'name': 'Physique',
            'description': 'Explorer les lois fondamentales qui régissent l\'univers.'
        },
        {
            'name': 'Chimie',
            'description': 'Étudier la composition, la structure et les propriétés de la matière.'
        }
    ]
    
    for user in User.objects.all():
        for category_data in DEFAULT_CATEGORIES:
            Category.objects.get_or_create(
                name=category_data['name'],
                user=user,
                defaults={'description': category_data['description']}
            )

class Migration(migrations.Migration):
    dependencies = [
        ('quiz', '0008_add_default_categories'),
    ]

    operations = [
        migrations.RunPython(ensure_french_categories, reverse_code=migrations.RunPython.noop),
    ] 