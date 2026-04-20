from typing import Annotated, Any, List, Optional
from langgraph.graph.message import add_messages
from typing_extensions import TypedDict


class AgentState(TypedDict):
    messages: Annotated[list, add_messages]
    current_action: Optional[str]
    user_id: Optional[int]
    expected_pill: Optional[str]
    identified_pills: Optional[List[str]]
    video_input: Optional[str]
    status: Optional[str]
    safety_alert: Optional[bool]