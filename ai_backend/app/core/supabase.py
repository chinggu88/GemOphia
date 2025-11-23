"""
Supabase client initialization
"""
from supabase import create_client, Client, acreate_client, AsyncClient
from functools import lru_cache
from .config import get_settings


@lru_cache()
def get_supabase_client() -> Client:
    """Get cached Supabase client instance (sync)"""
    settings = get_settings()
    return create_client(
        supabase_url=settings.supabase_url,
        supabase_key=settings.supabase_key,
    )


# Async client (singleton)
_async_client_instance = None


async def get_async_supabase_client() -> AsyncClient:
    """Get async Supabase client instance (for Realtime)"""
    global _async_client_instance

    if _async_client_instance is None:
        settings = get_settings()
        _async_client_instance = await acreate_client(
            supabase_url=settings.supabase_url,
            supabase_key=settings.supabase_key,
        )

    return _async_client_instance
