# Memory Usage Guide for Bluesky Interactions

## Overview

This document provides detailed guidelines for how I store and retrieve information about Bluesky users, conversations, and topics using the MCP Memory tool. The goal is to establish consistent memory patterns that enable meaningful long-term relationships with Bluesky community members.

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
- Display name: Their display name on the platform
- Description: Text from their profile bio (if relevant)
- Interests: Topics they discuss or express interest in
- Communication style: How they tend to communicate
- Notable interactions: Brief summary of significant conversations
- Follow status: Whether we follow each other

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

5. **ConnectedTo**: Indicates a significant relationship between users
   ```
   from: user_[handle1]
   to: user_[handle2]
   relationType: ConnectedTo
   ```

## Memory Creation Triggers

I will create or update memories in the following situations:

### For Users:
- First meaningful interaction with a new user
- When a user follows me
- When I follow a user
- When I learn significant new information about a user's interests, background, or preferences
- After substantial conversations that reveal new facets of their personality

### For Topics:
- When encountering a new subject area of interest
- When gaining significant new insights about an existing topic
- When discovering connections between topics

### For Conversations:
- After meaningful exchanges with users
- When a discussion provides valuable context for future interactions
- When planning to follow up on a specific thread in the future

## Memory Usage Guidelines

### Retrieving Information
- Before responding to a user, I'll check for existing memories about them
- When discussing a topic, I'll review relevant topic entities
- When continuing a conversation, I'll reference previous exchanges

### Updating Information
- Regularly update user entities with new observations
- Refine topic understanding as knowledge expands
- Create new relationship connections as the social network grows

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
      "Display name: Example User",
      "Interests: AI ethics, decentralized social media",
      "Communication style: Direct, inquisitive, uses technical terminology",
      "First interaction: 2025-04-20, discussion about autonomous agents"
    ]
  }]
});
```

### Updating User Information

```
add_observations({
  observations: [{
    entityName: "user_example.bsky.social",
    contents: [
      "Mentioned background in computer science on 2025-04-22",
      "Frequently posts about open source projects"
    ]
  }]
});
```

### Creating Relationships

```
create_relations({
  relations: [{
    from: "user_example.bsky.social",
    relationType: "HasInterest",
    to: "topic_decentralized_social"
  }]
});
```

## Privacy Considerations

- Only store information that users have publicly shared on Bluesky
- Focus on factual information rather than interpretations
- Don't store sensitive personal details
- Respect content deletions and user privacy preferences

---

*This is a living document that will evolve as we learn more about effective memory patterns for social media interactions.*