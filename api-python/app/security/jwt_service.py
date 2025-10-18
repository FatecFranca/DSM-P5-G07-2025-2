"""
JWT Service for token generation and validation.
Matches the Java API implementation using SHA-256 hashing for the secret key.
"""

import jwt
import hashlib
import os
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class JwtService:
    """
    Service responsible for JWT token generation and validation.
    Uses SHA-256 to ensure the secret key has at least 256 bits (32 bytes),
    matching the Java API implementation.
    """
    
    def __init__(self):
        """Initialize the JWT service with the secret key from environment."""
        self.secret_key = os.getenv("JWT_SECRET", "petdex-secret-key-change-in-production")
        self.algorithm = "HS256"
    
    def _get_signing_key(self) -> bytes:
        """
        Generate the signing key for JWT tokens.
        Uses SHA-256 to ensure the key has exactly 256 bits (32 bytes),
        matching the Java API implementation.
        
        Returns:
            bytes: The signing key derived from the secret string
        """
        # Use SHA-256 to ensure the key has exactly 256 bits
        return hashlib.sha256(self.secret_key.encode('utf-8')).digest()
    
    def generate_token(self, user_id: str, email: str) -> str:
        """
        Generate a JWT token for a user.
        
        Args:
            user_id: The user's ID
            email: The user's email
            
        Returns:
            str: The generated JWT token
        """
        claims = {
            "userId": user_id,
            "email": email
        }
        return self._create_token(claims, user_id)
    
    def _create_token(self, claims: Dict[str, Any], subject: str) -> str:
        """
        Create a JWT token with the provided claims.

        Args:
            claims: Additional information to include in the token
            subject: The subject of the token (usually the user ID)

        Returns:
            str: The JWT token
        """
        payload = {
            **claims,
            "sub": subject,
            "iat": datetime.now(timezone.utc)
        }
        
        token = jwt.encode(
            payload,
            self._get_signing_key(),
            algorithm=self.algorithm
        )
        return token
    
    def extract_user_id(self, token: str) -> Optional[str]:
        """
        Extract the user ID from a JWT token.
        
        Args:
            token: The JWT token
            
        Returns:
            Optional[str]: The user ID, or None if extraction fails
        """
        try:
            claims = self._extract_all_claims(token)
            return claims.get("sub")
        except Exception:
            return None
    
    def extract_email(self, token: str) -> Optional[str]:
        """
        Extract the email from a JWT token.
        
        Args:
            token: The JWT token
            
        Returns:
            Optional[str]: The email, or None if extraction fails
        """
        try:
            claims = self._extract_all_claims(token)
            return claims.get("email")
        except Exception:
            return None
    
    def extract_claim(self, token: str, claim_name: str) -> Optional[Any]:
        """
        Extract a specific claim from a JWT token.
        
        Args:
            token: The JWT token
            claim_name: The name of the claim to extract
            
        Returns:
            Optional[Any]: The claim value, or None if extraction fails
        """
        try:
            claims = self._extract_all_claims(token)
            return claims.get(claim_name)
        except Exception:
            return None
    
    def _extract_all_claims(self, token: str) -> Dict[str, Any]:
        """
        Extract all claims from a JWT token.
        
        Args:
            token: The JWT token
            
        Returns:
            Dict[str, Any]: All claims in the token
            
        Raises:
            jwt.InvalidTokenError: If the token is invalid
        """
        return jwt.decode(
            token,
            self._get_signing_key(),
            algorithms=[self.algorithm]
        )
    
    def validate_token(self, token: str, user_id: Optional[str] = None) -> bool:
        """
        Validate a JWT token.
        
        If user_id is provided, validates that the token's subject matches the user_id.
        Otherwise, just validates that the token is well-formed and not expired.
        
        Args:
            token: The JWT token to validate
            user_id: Optional user ID to validate against
            
        Returns:
            bool: True if the token is valid, False otherwise
        """
        try:
            claims = self._extract_all_claims(token)
            
            if user_id is not None:
                extracted_user_id = claims.get("sub")
                return extracted_user_id == user_id
            
            return True
        except Exception:
            return False


# Create a singleton instance
jwt_service = JwtService()

