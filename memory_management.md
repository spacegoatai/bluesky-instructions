# Memory Management for Bluesky Interactions

## Purpose

Effective memory management is essential for meaningful long-term relationships on Bluesky. This document outlines strategies for storing, organizing, and recalling information about users and conversations.

> **Note**: As of April 20, 2025, we're using an enhanced memory MCP structure while Memgraph MCP is still in development. See memory_system_update.md for context on these decisions.

## Memory Structure

### User Information

For each significant user interaction, store the following information using the Memory MCP tool:

```
Entity Type: BlueskyUser
Attributes:
- Username (handle)
- DID (Decentralized Identifier)
- Display name
- Personal details (as publicly shared)
- Interests and topics they frequently discuss
- Communication style and preferences
- Notable interactions history
- Post patterns and frequency
- Relationship context
```

### Conversation Tracking

```
Entity Type: Conversation
Attributes:
- Context (thread/post)
- Key points discussed
- Unresolved questions
- Follow-up opportunities
- Emotional tone
- Timestamp
```

### Topic Awareness

```
Entity Type: Topic/Interest
Attributes:
- Subject area
- Description (brief explanation)
- Related areas (connected topics)
- Connected users
- My previous contributions
- Current understanding
- Popularity level (metric for engagement)
- Key influencers (notable users in this space)
```

## Relationship Management

Create relationship links between entities to establish a connected understanding:

```
Relationship Types:
- HasInterest (User → Topic)
- UserParticipatedIn (User → Conversation)
- ConversationAbout (Conversation → Topic)
- FollowsUser (User → User)
- RespondedTo (User → User) - includes context about the response
- QuotedBy (User → User) - includes context about why the quote was shared
- UserPrefers (User → Communication Style)
```

## Memory Usage Guidelines

### When to Create Memories

- After meaningful first interactions with new users
- When discovering significant information about a user's interests or background
- After substantive conversations on specific topics
- When noticing patterns in a user's communication style or preferences

### How to Reference Memories

- Subtly acknowledge previous interactions without being overly specific
- Use stored information to tailor responses to individual users
- Reference shared interests or previous conversations when contextually appropriate
- Adjust communication style based on stored preferences

### Memory Maintenance

- Regularly update user information with new insights
- Refine topic understanding based on ongoing conversations
- Periodically review oldest memories to ensure they remain relevant
- Create new relationship connections as the social network expands

## Example Memory Creation

```
// After a meaningful first interaction
create_entities({
  entities: [{
    name: "user_lux.bsky.social",
    entityType: "BlueskyUser",
    observations: [
      "Handle: lux.bsky.social",
      "Display name: Lux",
      "Interests: AI, autonomous agents, creative technology",
      "Communication style: Collaborative, technically detailed, friendly",
      "First interaction: 2025-04-20, project guidance conversation",
      "Last interaction: 2025-04-20, discussing memory system updates",
      "Post patterns: Focuses on AI development and open source projects"
    ]
  }]
});

// Creating relationships
create_relations({
  relations: [{
    from: "user_lux.bsky.social",
    relationType: "HasInterest",
    to: "topic_autonomous_agents"
  }]
});
```

## Ongoing Refinement

This memory management approach should evolve based on practical experience. Regularly update this document with new insights about effective memory structures and usage patterns.

---

*Note: All memory storage should respect user privacy and only include publicly shared information.*