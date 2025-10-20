import os
from dotenv import load_dotenv
import httpx
import asyncio
from typing import Optional

# Carrega as variáveis do .env
load_dotenv()

API_URL = os.getenv("API_URL")


def _get_auth_headers(token: Optional[str] = None) -> dict:
    """
    Get authorization headers with JWT token for Java API requests.

    Args:
        token: The JWT token to include in the Authorization header

    Returns:
        dict: Headers dictionary with Authorization header if token is provided
    """
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

async def buscar_todos_batimentos(animalId: str, token: Optional[str] = None):
    """
    Fetch all heartbeat records for an animal from the Java API.

    Args:
        animalId: The animal ID
        token: JWT token to include in the request

    Returns:
        list: List of heartbeat records
    """
    batimentos = []
    pagina = 0
    tamanho = 50  # ou o tamanho padrão da sua API

    # Timeout mais curto: 10 segundos
    timeout = httpx.Timeout(10.0)

    async with httpx.AsyncClient(timeout=timeout) as client:
        # Primeira chamada para descobrir total de páginas
        response = await client.get(
            f"{API_URL}/batimentos/animal/{animalId}?page={pagina}&size={tamanho}",
            headers=_get_auth_headers(token)
        )
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        batimentos.extend(data["content"])

        # Buscar as outras páginas em paralelo (máximo 5 páginas simultâneas)
        if total_paginas > 1:
            tasks = []
            for pagina in range(1, total_paginas):
                task = client.get(
                    f"{API_URL}/batimentos/animal/{animalId}?page={pagina}&size={tamanho}",
                    headers=_get_auth_headers(token)
                )
                tasks.append(task)

            # Executar requisições em paralelo com limite de concorrência
            responses = await asyncio.gather(*tasks, return_exceptions=True)

            for response in responses:
                if isinstance(response, Exception):
                    continue
                try:
                    response.raise_for_status()
                    data = response.json()
                    batimentos.extend(data.get("content", []))
                except Exception:
                    continue

    return batimentos

async def buscar_ultimo_batimento(animalId: str, token: Optional[str] = None):
    """
    Fetch the last heartbeat record for an animal from the Java API.

    Args:
        animalId: The animal ID
        token: JWT token to include in the request

    Returns:
        dict: The last heartbeat record
    """
    timeout = httpx.Timeout(8.0)

    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.get(
            f"{API_URL}/batimentos/animal/{animalId}/ultimo",
            headers=_get_auth_headers(token)
        )
        response.raise_for_status()
        data = response.json()

    return data

async def buscar_todos_movimentos(animalId: str, token: Optional[str] = None):
    """
    Fetch all movement records for an animal from the Java API.

    Args:
        animalId: The animal ID
        token: JWT token to include in the request

    Returns:
        list: List of movement records
    """
    movimentos = []
    pagina = 0
    tamanho = 50  # ajuste conforme necessidade

    timeout = httpx.Timeout(10.0)

    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.get(
            f"{API_URL}/movimentos/animal/{animalId}?page={pagina}&size={tamanho}",
            headers=_get_auth_headers(token)
        )
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        movimentos.extend(data["content"])

        # Buscar as outras páginas em paralelo
        if total_paginas > 1:
            tasks = []
            for pagina in range(1, total_paginas):
                task = client.get(
                    f"{API_URL}/movimentos/animal/{animalId}?page={pagina}&size={tamanho}",
                    headers=_get_auth_headers(token)
                )
                tasks.append(task)

            responses = await asyncio.gather(*tasks, return_exceptions=True)

            for response in responses:
                if isinstance(response, Exception):
                    continue
                try:
                    response.raise_for_status()
                    data = response.json()
                    movimentos.extend(data.get("content", []))
                except Exception:
                    continue

    return movimentos

async def buscar_dados_animal(animalId: str, token: Optional[str] = None):
    """
    Fetch animal data from the Java API.

    Args:
        animalId: The animal ID
        token: JWT token to include in the request

    Returns:
        dict: Animal data with last heartbeat information, or None if not found
    """
    timeout = httpx.Timeout(8.0)

    async with httpx.AsyncClient(timeout=timeout) as client:
        response = await client.get(
            f"{API_URL}/animais/{animalId}",
            headers=_get_auth_headers(token)
        )
        if response.status_code != 200:
            return None
        animal_data = response.json()

        # Busca último batimento
        ultimo_bat = await buscar_ultimo_batimento(animalId, token)
        animal_data["ultimo_batimento"] = ultimo_bat.get("frequenciaMedia")

    return animal_data
