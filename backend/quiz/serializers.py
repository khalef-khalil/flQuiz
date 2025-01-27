from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from .models import Quiz, Question, Choice, QuizResult, UserProfile, Category

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email')

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        UserProfile.objects.create(user=user)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Incorrect Credentials")

class ChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Choice
        fields = ['id', 'text', 'is_correct']

class QuestionSerializer(serializers.ModelSerializer):
    choices = ChoiceSerializer(many=True)
    quiz = serializers.PrimaryKeyRelatedField(queryset=Quiz.objects.all(), required=False)

    class Meta:
        model = Question
        fields = ['id', 'text', 'order', 'choices', 'quiz']

    def create(self, validated_data):
        choices_data = validated_data.pop('choices')
        question = Question.objects.create(**validated_data)
        for choice_data in choices_data:
            Choice.objects.create(question=question, **choice_data)
        return question

class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = ['username', 'email', 'bio', 'quizzes_taken', 'average_score', 
                 'total_correct_answers', 'created_at']

class QuizResultSerializer(serializers.ModelSerializer):
    quiz_title = serializers.CharField(source='quiz.title', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = QuizResult
        fields = ['id', 'quiz_id', 'quiz_title', 'username', 'score', 
                 'completed_at', 'answers']
        read_only_fields = ['completed_at']

class CategorySerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'user']
        read_only_fields = ['user']

class QuizSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, required=False)
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    is_deleted = serializers.BooleanField(read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)
    difficulty_label = serializers.CharField(source='get_difficulty_display', read_only=True)

    class Meta:
        model = Quiz
        fields = ['id', 'title', 'description', 'created_at', 'questions', 
                 'user', 'is_deleted', 'category', 'category_name', 
                 'difficulty', 'difficulty_label', 'time_limit']

    def validate_difficulty(self, value):
        valid_difficulties = ['facile', 'moyen', 'difficile']
        if value not in valid_difficulties:
            raise serializers.ValidationError(
                f"La difficulté doit être l'une des suivantes : {', '.join(valid_difficulties)}"
            )
        return value

    def validate_time_limit(self, value):
        if value < 1:
            raise serializers.ValidationError("La durée doit être d'au moins 1 minute")
        if value > 180:  # 3 hours max
            raise serializers.ValidationError("La durée ne peut pas dépasser 180 minutes")
        return value

    def create(self, validated_data):
        questions_data = validated_data.pop('questions', [])
        quiz = Quiz.objects.create(**validated_data)
        
        for question_data in questions_data:
            choices_data = question_data.pop('choices', [])
            question = Question.objects.create(quiz=quiz, **question_data)
            
            for choice_data in choices_data:
                Choice.objects.create(question=question, **choice_data)
        
        return quiz 