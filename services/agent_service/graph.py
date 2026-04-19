"""LangGraph state machine for the agent service.

Wires all agent nodes (analyzer, context_loader, vision_node, safety_node, chat_node, logging_node)
into a compiled graph that can be invoked with state updates.
"""

from langgraph.graph import StateGraph, END
from .state import AgentState
from .agent import analyzer, context_loader, vision_node, safety_node, chat_node, logging_node


def route_from_analyzer(state: AgentState) -> str:
    """Conditional edge: route based on current_action from analyzer."""
    action = state.get("current_action")
    if action == "vision_tool":
        return "vision"
    elif action == "safety_check":
        return "safety"
    else:
        return "chat"


def build_graph() -> StateGraph:
    """Build and compile the agent state graph."""
    
    # Create the graph
    graph = StateGraph(AgentState)
    
    # Add all nodes
    graph.add_node("analyzer", analyzer)
    graph.add_node("context_loader", context_loader)
    graph.add_node("vision", vision_node)
    graph.add_node("safety", safety_node)
    graph.add_node("chat", chat_node)
    graph.add_node("logging", logging_node)
    
    # Set entry point
    graph.set_entry_point("analyzer")
    
    # Add edges from analyzer (conditional routing)
    graph.add_conditional_edges(
        "analyzer",
        route_from_analyzer,
        {
            "vision": "context_loader",  # vision_tool -> load context first
            "safety": "context_loader",  # safety_check -> load context first
            "chat": "chat"              # chat -> direct to chat node
        }
    )
    
    # Load context for vision and safety paths - use conditional routing
    graph.add_conditional_edges(
        "context_loader",
        lambda state: "vision" if state.get("current_action") == "vision_tool" else "safety",
        {"vision": "vision", "safety": "safety"}
    )
    
    # vision node can end or go to safety if interaction check needed
    graph.add_edge("vision", "logging")
    
    # safety node routes to logging
    graph.add_edge("safety", "logging")
    
    # chat node routes to logging
    graph.add_edge("chat", "logging")
    
    # logging node ends
    graph.add_edge("logging", END)
    
    # Compile the graph
    return graph.compile()


# Global compiled graph instance
agent_graph = build_graph()


def invoke_agent(state: AgentState) -> AgentState:
    """Invoke the agent graph with the given state.
    
    Args:
        state: AgentState with user_id, messages, etc.
        
    Returns:
        Updated AgentState with messages, status, etc.
    """
    return agent_graph.invoke(state)
