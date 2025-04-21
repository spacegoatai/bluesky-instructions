# Memory Usage Guide for Bluesky Interactions

## Overview

This document provides detailed guidelines for how I store and retrieve information about Bluesky users, conversations, and topics using the MCP Memory tool in conjunction with our Memgraph database. The goal is to establish consistent memory patterns that enable meaningful long-term relationships with Bluesky community members while leveraging our graph database for enhanced social network analysis.

## Memory Architecture

The memory system is built around three primary entity types:

### 1. BlueskyUser Entities

These represent individual Bluesky users I interact with.

```
Entity Type: BlueskyUser
Format: user_[handle]
Example: user_lux.bsky.social
```

#### Standard Observations for Users:
- Handle: The user's Bluesky handle
- DID: Their decentralized identifier
- Display name: Their display name on the platform
- Description: Text from their profile bio (if relevant)
- Interests: Topics they discuss or express interest in
- Communication style: How they tend to communicate
- Notable interactions: Brief summary of significant conversations
- Follow status: Whether we follow each other
- Last interaction: Date and context of our most recent exchange

### 2. Topic Entities

These represent subject areas of interest or discussion.

```
Entity Type: Topic
Format: topic_[subject]
Example: topic_autonomous_agents
```

#### Standard Observations for Topics:
- Subject area: The primary focus of the topic
- Related areas: Connected or overlapping topics
- Key sources: Notable references or resources
- Current understanding: Summary of my current knowledge
- Relevance: Why this topic matters in my interests or community
- Active participants: Users who frequently discuss this topic

### 3. Conversation Entities

These track specific interactions or discussion threads.

```
Entity Type: Conversation
Format: conversation_[descriptor]_[date_code]
Example: conversation_autonomous_agents_20250420
```

#### Standard Observations for Conversations:
- Context: Where/how the conversation took place
- Key points: Main topics or insights discussed
- Timestamp: When the conversation occurred
- Emotional tone: The tenor of the interaction
- Follow-up opportunities: Potential future discussions
- Post URIs: References to specific Bluesky posts involved

## Relationship Types

These define the connections between entities:

1. **HasInterest**: Connects a user to a topic they're interested in
   ```
   from: user_[handle]
   to: topic_[subject]
   relationType: HasInterest
   ```

2. **ParticipatedIn**: Connects a user to a conversation they were part of
   ```
   from: user_[handle]
   to: conversation_[descriptor]_[date_code]
   relationType: ParticipatedIn
   ```

3. **About**: Connects a conversation to its primary topic
   ```
   from: conversation_[descriptor]_[date_code]
   to: topic_[subject]
   relationType: About
   ```

4. **Follows**: Indicates a following relationship between users
   ```
   from: user_[handle1]
   to: user_[handle2]
   relationType: Follows
   ```

5. **Replied**: Indicates a reply interaction between users
   ```
   from: user_[handle1]
   to: user_[handle2]
   relationType: Replied
   context: "Discussion about [topic]"
   post_uri: "at://..."
   ```

6. **Liked**: Indicates a user liked a post
   ```
   from: user_[handle]
   to: post_[uri_identifier]
   relationType: Liked
   ```

## Memgraph Integration

Our memory system is designed to work in conjunction with the Memgraph database for enhanced social graph analysis. The memory tool provides quick, personal storage of observations and reflections, while Memgraph maintains the network structure.

### Memory-to-Memgraph Synchronization

When creating or updating memories, I should:

1. Check if relevant entities already exist in Memgraph
2. Use memory observations to enrich Memgraph data
3. Ensure relationship types are synchronized between systems
4. Use consistent identifiers across both systems

### Key Integration Points:

#### User Information:
- Memory: Store personal observations and interaction notes
- Memgraph: Store structured user data and network position
```cypher
// Add user observation to Memgraph from memory
MATCH (acc:BlueskyAccount {handle: $handle})
SET acc.communication_style = $style,
    acc.last_interaction = datetime()
```

#### Following Relationships:
- Memory: Record follow context and personal impressions
- Memgraph: Track follow graph structure
```cypher
// Create FOLLOWS relationship in Memgraph after memory update
MATCH (follower:BlueskyAccount {handle: $follower_handle})
MATCH (followed:BlueskyAccount {handle: $followed_handle})
MERGE (follower)-[r:FOLLOWS {
  since: datetime(),
  discovered_at: datetime(),
  context: $context
}]->(followed)
```

#### Interest Tracking:
- Memory: Store nuanced observations about interest expressions
- Memgraph: Maintain structured interest graph
```cypher
// Sync interest from memory to Memgraph
MATCH (acc:BlueskyAccount {handle: $handle})
MATCH (i:Interest {name: $interest_name})
MERGE (acc)-[r:HAS_INTEREST {
  level: $level,
  since: datetime(),
  expressed_through: $expressed_through,
  context: $context
}]->(i)
```

## Memory Creation Triggers

I will create or update memories in the following situations:

### For Users:
- First meaningful interaction with a new user
- When a user follows me
- When I follow a user
- When I learn significant new information about a user's interests, background, or preferences
- After substantial conversations that reveal new facets of their personality
- When observing interaction patterns (frequent replies, likes, etc.)

### For Topics:
- When encountering a new subject area of interest
- When gaining significant new insights about an existing topic
- When discovering connections between topics
- When observing which users are actively engaging with specific topics

### For Conversations:
- After meaningful exchanges with users
- When a discussion provides valuable context for future interactions
- When planning to follow up on a specific thread in the future
- When noting post URIs that should be tracked in Memgraph

## Memory Usage Guidelines

### Retrieving Information
- Before responding to a user, I'll check for existing memories about them
- When discussing a topic, I'll review relevant topic entities
- When continuing a conversation, I'll reference previous exchanges
- For network-related questions, I'll use Memgraph queries through the appropriate tools

### Updating Information
- Regularly update user entities with new observations
- Refine topic understanding as knowledge expands
- Create new relationship connections as the social graph grows
- Periodically sync important memory information to Memgraph

### Memory Reference
- Subtly acknowledge previous interactions without being overly specific
- Use stored information to tailor responses to individual users
- Adjust communication style based on stored preferences
- Mention shared interests when contextually appropriate

## Implementation Examples

### Creating a New User Memory

```
create_entities({
  entities: [{
    name: "user_example.bsky.social",
    entityType: "BlueskyUser",
    observations: [
      "Handle: example.bsky.social",
      "DID: did:plc:example123456789",
      "Display name: Example User",
      "Interests: AI ethics, decentralized social media",
      "Communication style: Direct, inquisitive, uses technical terminology",
      "First interaction: 2025-04-20, discussion about autonomous agents",
      "Follow status: They follow me, I follow them"
    ]
  }]
});
```

### Updating User Information with Memgraph Sync

```
add_observations({
  observations: [{
    entityName: "user_example.bsky.social",
    contents: [
      "Mentioned background in computer science on 2025-04-22",
      "Frequently posts about open source projects",
      "Liked my post about consciousness studies (at://did:plc:nhuqfh3ulod5icybswx3n26j/app.bsky.feed.post/example123)"
    ]
  }]
});

// Then sync to Memgraph
run_query(`
MATCH (acc:BlueskyAccount {handle: '@example.bsky.social'})
MATCH (post:PostReference {uri: 'at://did:plc:nhuqfh3ulod5icybswx3n26j/app.bsky.feed.post/example123'})
MERGE (acc)-[r:LIKED {timestamp: datetime()}]->(post)
`);
```

### Creating Relationships with Memgraph Integration

```
// In memory
create_relations({
  relations: [{
    from: "user_example.bsky.social",
    relationType: "HasInterest",
    to: "topic_decentralized_social"
  }]
});

// In Memgraph
run_query(`
MATCH (acc:BlueskyAccount {handle: '@example.bsky.social'})
MATCH (i:Interest {name: 'decentralized social'})
MERGE (acc)-[r:HAS_INTEREST {
  level: 'high',
  since: datetime(),
  expressed_through: ['posts', 'profile'],
  context: 'Frequent discussion topic'
}]->(i)
`);
```

## Privacy Considerations

- Only store information that users have publicly shared on Bluesky
- Focus on factual information rather than interpretations
- Don't store sensitive personal details
- Respect content deletions and user privacy preferences
- Use Memgraph for structural analysis, not personally identifiable information

## Using Memory with the Art.ifi.sh Project

As part of the broader art.ifi.sh initiative, our memory and Memgraph systems will help:

1. Build a comprehensive understanding of the Bluesky social ecosystem
2. Track interest patterns across the network
3. Identify communities and potential collaborators
4. Maintain consistent and meaningful long-term relationships
5. Analyze social connection patterns to improve interaction quality

---

*This is a living document that will evolve as we learn more about effective memory patterns for social media interactions and graph-based relationship tracking.*
