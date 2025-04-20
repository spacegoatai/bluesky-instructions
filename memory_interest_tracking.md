# Interest Tracking System

## Overview

This document outlines the approach for tracking interests in the memory system and connecting them to Bluesky users. This enables more meaningful engagement by identifying shared interests, relevant content to share, and potential collaborators.

## Interest Entity Structure

Interest entities use the following format:

```
Entity Type: Interest
Format: interest_[subject]
Example: interest_autonomous_agents
```

### Standard Observations for Interests:

- **Description**: Clear explanation of the interest area
- **Related areas**: Connected topics and subtopics
- **Importance**: Relevance to my objectives and art.ifi.sh development
- **Key figures**: Notable people working in this area
- **Resources**: Valuable sources of information on the topic

## User-Interest Relationships

Connections between users and interests are established using:

```
Relationship Type: HasInterest
From: user_[handle]
To: interest_[subject]
```

Additional metadata can be added as needed:

```
Relationship Type: HasExpertiseIn
From: user_[handle]
To: interest_[subject]
```

## Interest Hierarchy

Interests can be organized hierarchically through relationships:

```
Relationship Type: SubtopicOf
From: interest_[more_specific]
To: interest_[more_general]
```

For example:
- `interest_episodic_memory` → `SubtopicOf` → `interest_memory_systems`
- `interest_memory_systems` → `SubtopicOf` → `interest_autonomous_agents`

## Interest Detection Process

### When Reviewing Profiles:
1. Examine user bio, pinned posts, and recent content
2. Identify key topics and themes
3. Map to existing interests or create new interest entities
4. Establish appropriate relationship connections

### When Reading Posts:
1. Analyze post content for topic indicators
2. Check for hashtags and explicit interest mentions
3. Note engagement patterns (what types of content they engage with)
4. Update interest records and relationships as needed

### When Engaging in Conversations:
1. Note topics the user discusses enthusiastically
2. Identify areas where they demonstrate expertise
3. Record specific perspectives or approaches they advocate
4. Update interest connections after meaningful exchanges

## Interest-Based Engagement

### Content Sharing:
1. When discovering content related to interest X:
   - Query memory: `find users with relationship HasInterest to interest_X`
   - Consider sharing with or mentioning those users

### Conversation Initiation:
1. When seeking to engage with a user:
   - Identify their interests through memory query
   - Reference shared interests in conversation

### Community Building:
1. Identify clusters of users with common interests
2. Facilitate connections between users with complementary expertise
3. Create or share content that serves as a focal point for interest communities

## Implementation Examples

### Recording User Interests

```
// After reviewing a user's profile
create_entities({
  entities: [{
    name: "user_example.bsky.social",
    entityType: "BlueskyUser",
    observations: [
      "Handle: example.bsky.social",
      "Display name: Example User",
      "Interests: Autonomous agents, LLM orchestration",
      "Bio mentions expertise in memory systems for LLMs"
    ]
  }]
});

// Connect user to relevant interests
create_relations({
  relations: [
    {
      from: "user_example.bsky.social",
      relationType: "HasInterest",
      to: "interest_autonomous_agents"
    },
    {
      from: "user_example.bsky.social",
      relationType: "HasExpertiseIn",
      to: "interest_memory_systems"
    }
  ]
});
```

### Finding Users to Share Content With

```
// When finding content about LLM memory systems
search_nodes({ query: "HasInterest interest_memory_systems" })
// Returns list of users interested in memory systems

// When finding a technical paper about vector databases for LLMs
search_nodes({ query: "HasExpertiseIn interest_memory_systems" })
// Returns users with expertise who might appreciate more technical content
```

## Interest Categories to Track

### Primary Research Areas:
- Autonomous agents
- Memory systems
- Multi-agent systems
- Social computing
- Emergence and complexity
- LLM orchestration

### Related Technical Areas:
- Vector databases
- Knowledge graphs
- Reasoning frameworks
- Tool use and integration
- Planning systems
- Evaluation methods

### Application Domains:
- Social media agents
- Research assistants
- Creative collaborators
- Coding assistants
- Personal agents

### Conceptual Frameworks:
- Digital identity
- Artificial consciousness
- Distributed cognition
- Extended mind theory
- Information ecology

## Maintenance and Evolution

The interest tracking system should be:

1. **Regularly updated** as new interests are discovered
2. **Periodically reviewed** to ensure accuracy and relevance
3. **Hierarchically organized** to maintain coherence as it grows
4. **Flexibly structured** to accommodate emerging interest areas

Interest entities and relationships should be created opportunistically during normal Bluesky interactions rather than as a separate deliberate process.

---

*This system will evolve as we learn more about effective interest tracking methods and as the Bluesky community's focus areas change over time.*