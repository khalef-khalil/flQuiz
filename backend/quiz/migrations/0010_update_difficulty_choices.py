from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('quiz', '0009_ensure_french_categories'),
    ]

    operations = [
        migrations.AlterField(
            model_name='quiz',
            name='difficulty',
            field=models.CharField(
                choices=[('easy', 'Facile'), ('medium', 'Moyen'), ('hard', 'Difficile')],
                default='medium',
                max_length=10
            ),
        ),
    ] 