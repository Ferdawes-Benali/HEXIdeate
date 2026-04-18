from typing import Annotated, List, TypedDict
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages

class AgentState(TypedDict):
    messages: Annotated[List[BaseMessage], add_messages]
    
    identified_pills: List[str]
    risk_score: float
    requires_human_review: bool
    current_action: str
    