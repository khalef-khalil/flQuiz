from django.db import migrations

def assign_categories_to_admin(apps, schema_editor):
    Category = apps.get_model('quiz', 'Category')
    User = apps.get_model('auth', 'User')
    
    # Get the first admin user, or create one if none exists
    admin_user = User.objects.filter(is_superuser=True).first()
    if not admin_user:
        return
        
    # Assign all existing categories without a user to the admin user
    Category.objects.filter(user__isnull=True).update(user=admin_user)

class Migration(migrations.Migration):
    dependencies = [
        ('quiz', '0005_category_user_alter_category_name_and_more'),
    ]

    operations = [
        migrations.RunPython(assign_categories_to_admin, reverse_code=migrations.RunPython.noop),
    ] 