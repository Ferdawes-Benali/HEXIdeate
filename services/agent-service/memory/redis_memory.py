import json
import redis
from config import settings

_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

HISTORY_TTL = 60 * 60 * 6 

def get_history(user_id: int) -> list[dict]:
    """Return the stored conversation history for a user."""
    raw_list = _client.lrange(f"history:{user_id}", 0, -1)
    return [json.loads(msg) for msg in raw_list]

def append_message(user_id: int, role: str, content: str) -> None:
    """Atomic append using Redis Lists."""
    key = f"history:{user_id}"
    message = json.dumps({"role": role, "content": content})
    
    pipe = _client.pipeline()
    pipe.rpush(key, message)    
    pipe.ltrim(key, -20, -1)      
    pipe.expire(key, HISTORY_TTL) 
    pipe.execute()

def clear_history(user_id: int) -> None:
    _client.delete(f"history:{user_id}")