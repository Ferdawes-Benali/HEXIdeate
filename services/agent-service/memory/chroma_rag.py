import os
import hashlib
from langchain_chroma import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_core.documents import Document
from config import settings

ABS_PATH = os.path.abspath("./chroma_db")

_embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key=settings.GOOGLE_API_KEY,
)

_vectorstore = Chroma(
    collection_name="medmind_knowledge",
    embedding_function=_embeddings,
    persist_directory=ABS_PATH,
)

def add_documents(docs: list[Document]) -> None:
    """Upsert documents with deterministic IDs to prevent duplicates."""
    ids = [hashlib.md5(d.page_content.encode()).hexdigest() for d in docs]
    _vectorstore.add_documents(documents=docs, ids=ids)

def similarity_search(query: str, k: int = 4) -> list[Document]:
    """Return the top-k most relevant documents for a query."""
    return _vectorstore.similarity_search(query, k=k)

def build_rag_context(query: str, k: int = 4) -> str:
    """
    Runs similarity search and returns a single concatenated context string.
    """
    results = similarity_search(query, k=k)
    if not results:
        return ""
    return "\n\n".join(doc.page_content for doc in results)