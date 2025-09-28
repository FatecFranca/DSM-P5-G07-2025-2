import os
from dotenv import load_dotenv
import httpx

# Carrega as variáveis do .env
load_dotenv()

API_URL = os.getenv("API_BATIMENTOS_URL")
API_MOVIMENTOS_URL = os.getenv("API_MOVIMENTOS_URL")

async def buscar_todos_batimentos():
    batimentos = []
    pagina = 0
    tamanho = 50  # ou o tamanho padrão da sua API

    async with httpx.AsyncClient() as client:
        # Primeira chamada para descobrir total de páginas
        response = await client.get(f"{API_URL}?page={pagina}&size={tamanho}")
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        batimentos.extend(data["content"])

        # Buscar as outras páginas (se houver)
        for pagina in range(1, total_paginas):
            response = await client.get(f"{API_URL}?page={pagina}&size={tamanho}")
            response.raise_for_status()
            data = response.json()
            batimentos.extend(data["content"])

    return batimentos


# ✅ NOVA FUNÇÃO: busca todos os movimentos
async def buscar_todos_movimentos():
    movimentos = []
    pagina = 0
    tamanho = 50  # ajuste conforme necessidade

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_MOVIMENTOS_URL}?page={pagina}&size={tamanho}")
        response.raise_for_status()
        data = response.json()

        total_paginas = data.get("totalPages", 1)
        movimentos.extend(data["content"])

        for pagina in range(1, total_paginas):
            response = await client.get(f"{API_MOVIMENTOS_URL}?page={pagina}&size={tamanho}")
            response.raise_for_status()
            data = response.json()
            movimentos.extend(data["content"])

    return movimentos
