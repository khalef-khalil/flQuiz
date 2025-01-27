import logging
from rest_framework import permissions

logger = logging.getLogger(__name__)

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        logger.debug(f'Checking permission for user {request.user} on {view.__class__.__name__}')
        logger.debug(f'Request method: {request.method}')
        logger.debug(f'Request headers: {request.headers}')
        logger.debug(f'Auth: {request.auth}')
        return bool(request.user and request.user.is_authenticated)

    def has_object_permission(self, request, view, obj):
        logger.debug(f'Checking object permission for user {request.user} on {obj}')
        logger.debug(f'Request method: {request.method}')
        logger.debug(f'Object owner: {obj.user}')
        
        if request.method in permissions.SAFE_METHODS:
            logger.debug('Safe method, allowing read access')
            return True

        is_owner = obj.user == request.user
        logger.debug(f'User is owner: {is_owner}')
        return is_owner 