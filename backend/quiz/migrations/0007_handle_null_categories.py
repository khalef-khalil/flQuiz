from django.db import migrations, models

def handle_null_categories(apps, schema_editor):
    Category = apps.get_model('quiz', 'Category')
    User = apps.get_model('auth', 'User')
    
    # Get the first user, or create one if none exists
    default_user = User.objects.first()
    if not default_user:
        return
        
    # Assign any remaining categories with null users to the default user
    Category.objects.filter(user__isnull=True).update(user=default_user)

class Migration(migrations.Migration):
    dependencies = [
        ('quiz', '0006_assign_categories_to_admin'),
    ]

    operations = [
        migrations.RunPython(handle_null_categories),
        migrations.AlterField(
            model_name='category',
            name='user',
            field=models.ForeignKey(on_delete=models.deletion.CASCADE, related_name='categories', to='auth.user'),
        ),
    ] 