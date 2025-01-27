import logging
from django.shortcuts import render
from rest_framework import viewsets, generics, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.contrib.auth import login
from rest_framework.authtoken.models import Token
from django.shortcuts import get_object_or_404
from django.db.models import Q
from rest_framework.parsers import JSONParser
from .models import Quiz, Question, Choice, QuizResult, UserProfile, Category
from .permissions import IsOwnerOrReadOnly
from .serializers import (
    QuizSerializer, QuestionSerializer, ChoiceSerializer,
    UserSerializer, RegisterSerializer, LoginSerializer,
    QuizResultSerializer, UserProfileSerializer, CategorySerializer
)

logger = logging.getLogger(__name__)

# Create your views here.

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

class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    parser_classes = [JSONParser]

    def post(self, request, *args, **kwargs):
        logger.info(f'Registration attempt for user: {request.data.get("username")}')
        logger.debug(f'Request headers: {request.headers}')
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Create default categories for the new user
        for category_data in DEFAULT_CATEGORIES:
            Category.objects.create(
                name=category_data['name'],
                description=category_data['description'],
                user=user
            )
        
        token, _ = Token.objects.get_or_create(user=user)
        logger.info(f'Registration successful for user: {user.username}')
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key
        })

class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]
    parser_classes = [JSONParser]

    def post(self, request, *args, **kwargs):
        logger.info(f'Login attempt for user: {request.data.get("username")}')
        logger.debug(f'Request headers: {request.headers}')
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        token, _ = Token.objects.get_or_create(user=user)
        logger.info(f'Login successful for user: {user.username}')
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key
        })

class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    parser_classes = [JSONParser]

    def get_queryset(self):
        return Category.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def list(self, request, *args, **kwargs):
        # Include both user's custom categories and default categories
        user_categories = Category.objects.filter(user=request.user)
        return Response(self.get_serializer(user_categories, many=True).data)

class QuizViewSet(viewsets.ModelViewSet):
    serializer_class = QuizSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]
    parser_classes = [JSONParser]

    def get_queryset(self):
        logger.debug(f"Fetching quizzes for user {self.request.user}")
        queryset = Quiz.objects.filter(user=self.request.user, is_deleted=False)
        logger.debug(f"Found {queryset.count()} quizzes")
        for quiz in queryset:
            logger.debug(f"Quiz: {quiz.id} - {quiz.title} - Category: {quiz.category_id} - {quiz.category.name if quiz.category else 'No category'}")
        return queryset

    def perform_create(self, serializer):
        logger.debug(f"Creating quiz for user {self.request.user}")
        logger.debug(f"Quiz data: {serializer.validated_data}")
        serializer.save(user=self.request.user)

    def retrieve(self, request, *args, **kwargs):
        logger.debug(f"Retrieving quiz {kwargs.get('pk')} for user {request.user}")
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        logger.debug(f"Quiz data: {serializer.data}")
        return Response(serializer.data)

    def list(self, request, *args, **kwargs):
        logger.debug(f"Listing quizzes for user {request.user}")
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        logger.debug(f"Serialized data: {serializer.data}")
        return Response(serializer.data)

    def update(self, request, *args, **kwargs):
        logger.debug(f"Updating quiz {kwargs.get('pk')} for user {request.user}")
        logger.debug(f"Update data: {request.data}")
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        logger.debug(f"Soft deleting quiz {kwargs.get('pk')} for user {request.user}")
        instance = self.get_object()
        instance.is_deleted = True
        instance.save()
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=['post'])
    def submit_result(self, request, pk=None):
        logger.debug(f"Submitting result for quiz {pk} by user {request.user}")
        logger.debug(f"Result data: {request.data}")
        quiz = self.get_object()
        
        # Create quiz result
        result = QuizResult.objects.create(
            user=request.user,
            quiz=quiz,
            score=request.data['score'],
            answers=request.data['answers']
        )
        
        # Update user profile stats
        profile = request.user.profile
        profile.update_stats(
            new_score=request.data['score'],
            correct_answers=request.data['correct_answers']
        )
        
        serializer = QuizResultSerializer(result)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def difficulties(self, request):
        logger.debug("Fetching difficulty choices")
        difficulties = [
            {'value': choice[0], 'label': choice[1]}
            for choice in Quiz.DIFFICULTY_CHOICES
        ]
        logger.debug(f"Difficulty choices: {difficulties}")
        return Response(difficulties)

class QuestionViewSet(viewsets.ModelViewSet):
    serializer_class = QuestionSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser]

    def get_queryset(self):
        return Question.objects.filter(quiz__user=self.request.user)

    def perform_create(self, serializer):
        quiz = get_object_or_404(Quiz, pk=self.request.data.get('quiz'))
        if quiz.user != self.request.user:
            raise permissions.PermissionDenied("You don't have permission to add questions to this quiz.")
        serializer.save()

class ChoiceViewSet(viewsets.ModelViewSet):
    serializer_class = ChoiceSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser]

    def get_queryset(self):
        return Choice.objects.filter(question__quiz__user=self.request.user)

    def perform_create(self, serializer):
        question = get_object_or_404(Question, pk=self.request.data.get('question'))
        if question.quiz.user != self.request.user:
            raise permissions.PermissionDenied("You don't have permission to add choices to this question.")
        serializer.save()

class QuizResultViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = QuizResultSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser]

    def get_queryset(self):
        return QuizResult.objects.filter(user=self.request.user)

class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser]

    def get_object(self):
        profile, created = UserProfile.objects.get_or_create(user=self.request.user)
        return profile
