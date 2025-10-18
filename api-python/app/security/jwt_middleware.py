"""
JWT Authentication middleware and decorator for FastAPI.
Validates JWT tokens from incoming requests.
"""

from fastapi import HTTPException, Depends, status, Header
from typing import Optional, Tuple
from app.security.jwt_service import jwt_service


async def verify_jwt_token(authorization: Optional[str] = Header(None)) -> Tuple[str, str]:
    """
    Dependency function to verify JWT token from Authorization header.

    Extracts the token from the "Authorization: Bearer <token>" header
    and validates it.

    Args:
        authorization: The Authorization header value

    Returns:
        Tuple[str, str]: A tuple of (user_id, token)

    Raises:
        HTTPException: If the token is invalid or missing
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Extract token from "Bearer <token>" format
    token = get_token_from_header(authorization)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format. Expected: Bearer <token>",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Validate the token
    if not jwt_service.validate_token(token):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Extract user ID from token
    user_id = jwt_service.extract_user_id(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token: missing user ID",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user_id, token


async def get_current_user(credentials: Tuple[str, str] = Depends(verify_jwt_token)) -> Tuple[str, str]:
    """
    Dependency function to get the current authenticated user and token.

    Args:
        credentials: A tuple of (user_id, token) from verify_jwt_token

    Returns:
        Tuple[str, str]: A tuple of (user_id, token)
    """
    return credentials


def get_token_from_header(authorization: Optional[str] = None) -> Optional[str]:
    """
    Extract JWT token from Authorization header.
    
    Args:
        authorization: The Authorization header value
        
    Returns:
        Optional[str]: The token if present and valid format, None otherwise
    """
    if not authorization:
        return None
    
    if not authorization.startswith("Bearer "):
        return None
    
    return authorization[7:]  # Remove "Bearer " prefix

