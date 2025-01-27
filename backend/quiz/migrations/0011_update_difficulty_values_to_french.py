from django.db import migrations, models

def update_difficulty_values(apps, schema_editor):
    Quiz = apps.get_model('quiz', 'Quiz')
    # Update existing records
    difficulty_mapping = {
        'easy': 'facile',
        'medium': 'moyen',
        'hard': 'difficile'
    }
    for quiz in Quiz.objects.all():
        quiz.difficulty = difficulty_mapping.get(quiz.difficulty, 'moyen')
        quiz.save()

class Migration(migrations.Migration):
    dependencies = [
        ('quiz', '0010_update_difficulty_choices'),
    ]

    operations = [
        migrations.AlterField(
            model_name='quiz',
            name='difficulty',
            field=models.CharField(
                choices=[('facile', 'Facile'), ('moyen', 'Moyen'), ('difficile', 'Difficile')],
                default='moyen',
                max_length=10
            ),
        ),
        migrations.RunPython(update_difficulty_values, reverse_code=migrations.RunPython.noop),
    ] 