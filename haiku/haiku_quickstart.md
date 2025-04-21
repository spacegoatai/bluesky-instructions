# Haiku Quickstart Guide for Bluesky Operations

This guide provides a clear, step-by-step approach for working with Bluesky users and storing their data in Memgraph. Unlike the main documentation, this guide focuses on working with the current implementation specificities.

## Core Task Flow

This guide focuses on these specific operations:
1. Looking up a Bluesky user
2. Retrieving their followers
3. Adding users to Memgraph as nodes
4. Updating relationship data (follows)

## Working with Bluesky API

### Looking Up a User

```javascript
// Get profile information for a user
// IMPORTANT: Do NOT include the @ symbol in the handle
const profileResult = await bluesky_get_profile({
  actor: 'username.bsky.social'  // Without the @ symbol
});

// Sample response will include:
// - did: The decentralized identifier
// - handle: The user's handle
// - displayName: The user's display name
// - description: Bio information
// - followsCount: Number of accounts they follow
// - followersCount: Number of followers
```

### Getting a User's Followers

```javascript
// Get followers for a user
// IMPORTANT: Do NOT include the @ symbol in the handle
const followersResult = await bluesky_get_followers({
  actor: 'username.bsky.social',  // Without the @ symbol
  limit: 50 // Optional, defaults to 25
});

// Sample response structure:
// - followers: Array of follower objects
//   - did: Follower's DID
//   - handle: Follower's handle
//   - displayName: Follower's display name
// - cursor: Pagination cursor for next page
```

## Working with Memgraph

The current Memgraph implementation requires **one operation per query**. This is different from standard Cypher where you can chain multiple operations.

### Important Rules

1. **One operation per query**: Split your work into individual queries
2. **Test step by step**: Start simple and build up complexity
3. **Verify before modifying**: Check if nodes exist before creating relationships

### Testing Your Memgraph Connection

Always start with a simple query to verify your connection is working:

```javascript
// Simple test query
const testResult = await run_query({
  query: `
    RETURN "Testing Memgraph connection";
  `
});
```

### Adding User Nodes to Memgraph

```javascript
// IMPORTANT: Each CREATE statement must be in its own query!

// Create a single user node
// This is the format that works with our implementation
const result = await run_query({
  query: `
    CREATE (u:BlueskyAccount {
      did: '${user.did}',
      handle: '${user.handle}',
      display_name: '${user.displayName || ""}',
      followers_count: ${user.followersCount || 0},
      follows_count: ${user.followsCount || 0},
      first_seen: datetime()
    });
  `
});

// Verify node was created
const verifyResult = await run_query({
  query: `
    MATCH (u:BlueskyAccount {handle: '${user.handle}'})
    RETURN u;
  `
});
```

### Adding Interest Nodes

```javascript
// Create an interest node - ONE AT A TIME
const interestResult = await run_query({
  query: `
    CREATE (i:Interest {
      name: 'AI Research',
      description: 'Research on artificial intelligence'
    });
  `
});
```

### Creating Relationships

```javascript
// Create a FOLLOWS relationship between users
// First verify both users exist, then create relationship
const relationshipResult = await run_query({
  query: `
    MATCH (a:BlueskyAccount {handle: 'follower.bsky.social'})
    MATCH (b:BlueskyAccount {handle: 'followed.bsky.social'})
    CREATE (a)-[:FOLLOWS {since: datetime()}]->(b);
  `
});

// Create a HAS_INTEREST relationship
const interestRelationshipResult = await run_query({
  query: `
    MATCH (u:BlueskyAccount {handle: 'username.bsky.social'})
    MATCH (i:Interest {name: 'AI Research'})
    CREATE (u)-[:HAS_INTEREST {confidence: 0.8}]->(i);
  `
});
```

## Complete Example Workflow

Here's a full example of looking up a user, getting their followers, and adding everything to Memgraph:

```javascript
// Step 1: Look up the user
const profile = await bluesky_get_profile({
  actor: 'emergentvibe.bsky.social'  // WITHOUT the @ symbol
});

// Step 2: Add the user to Memgraph (if not already there)
await run_query({
  query: `
    CREATE (u:BlueskyAccount {
      did: '${profile.did}',
      handle: '${profile.handle}',
      display_name: '${profile.displayName || ""}',
      followers_count: ${profile.followersCount},
      follows_count: ${profile.followsCount},
      first_seen: datetime()
    });
  `
});

// Step 3: Get their followers
const followers = await bluesky_get_followers({
  actor: 'emergentvibe.bsky.social',  // WITHOUT the @ symbol
  limit: 50
});

// Step 4: Add each follower to Memgraph (one at a time)
for (const follower of followers.followers) {
  // Create follower node
  await run_query({
    query: `
      CREATE (u:BlueskyAccount {
        did: '${follower.did}',
        handle: '${follower.handle}',
        display_name: '${follower.displayName || ""}',
        first_seen: datetime()
      });
    `
  });
  
  // Create FOLLOWS relationship
  await run_query({
    query: `
      MATCH (a:BlueskyAccount {did: '${follower.did}'})
      MATCH (b:BlueskyAccount {did: '${profile.did}'})
      CREATE (a)-[:FOLLOWS {since: datetime()}]->(b);
    `
  });
}

// Step 5: Verify the network has been created
const verifyNetwork = await run_query({
  query: `
    MATCH (follower:BlueskyAccount)-[:FOLLOWS]->(u:BlueskyAccount {handle: '${profile.handle}'})
    RETURN follower.handle, u.handle;
  `
});
```

## Troubleshooting

### Common Error: Multiple Statements
```
Error: {code: Memgraph.ClientError.MemgraphError.MemgraphError} {message: Error on line 12 position 1. The underlying parsing error is mismatched input 'CREATE' expecting <EOF>}
```

This means you're trying to run multiple statements in one query. Split them into separate queries.

### API Format Errors
```
Error executing code: MCP error -32603: Error: actor must be a valid did or a handle
```

If you see this error, double-check your handle format. Make sure you're:
- NOT including the @ symbol
- Using the correct handle (e.g., 'emergentvibe.bsky.social')

## Next Steps

After mastering these basic operations, you can:

1. Build more complex queries to analyze network connections
2. Track user interests and community clusters
3. Monitor relationship changes over time
4. Develop recommendation systems based on shared interests

Remember, consistency is key with Memgraph - stick to single operations per query and verify each step works before proceeding to the next.
