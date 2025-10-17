import os
from dotenv import load_dotenv
import httpx

# Carrega as variáveis do .env
load_dotenv()

API_URL = os.getenv("API_URL")

async def buscar_todos_batimentos(animalId: str):
    batimentos = []
    pagina = 0
    tamanho = 50  # ou o tamanho padrão da sua API

    async with httpx.AsyncClient() as client:
        # Primeira chamada para descobrir total de páginas
        response = await client.get(f"{API_URL}/batimentos/animal/{animalId}?page={pagina}&size={tamanho}")
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        batimentos.extend(data["content"])

        # Buscar as outras páginas (se houver)
        for pagina in range(1, total_paginas):
            response = await client.get(f"{API_URL}/batimentos/animal/{animalId}?page={pagina}&size={tamanho}")
            response.raise_for_status()
            data = response.json()
            batimentos.extend(data["content"])

    return batimentos

async def buscar_ultimo_batimento(animalId: str):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_URL}/batimentos/animal/{animalId}/ultimo")
        response.raise_for_status()
        data = response.json()

    return data

async def buscar_todos_movimentos(animalId: str):
    movimentos = []
    pagina = 0
    tamanho = 50  # ajuste conforme necessidade

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_MOVIMENTOS_URL}/movimentos/animal/{animalId}?page={pagina}&size={tamanho}")
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        movimentos.extend(data["content"])

        for pagina in range(1, total_paginas):
            response = await client.get(f"{API_MOVIMENTOS_URL}/movimentos/animal/{animalId}?page={pagina}&size={tamanho}")
            response.raise_for_status()
            data = response.json()
            movimentos.extend(data["content"])

    return movimentos

async def buscar_dados_animal(animalId: str):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_URL}/animais/{animalId}")
        if response.status_code != 200:
            return None
        animal_data = response.json()

        # Busca último batimento
        ultimo_bat = await buscar_ultimo_batimento(animalId)
        animal_data["ultimo_batimento"] = ultimo_bat.get("frequenciaMedia")

    return animal_data
