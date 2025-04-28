# Bluesky MCP Capabilities Analysis

## Available Functions

Based on an analysis of the current Bluesky MCP implementation, these are the functions we can access:

### Content Creation
- `bluesky_post` - Post short messages (up to 300 characters)
- `bluesky_create_draft` - Create long-form content drafts
- `bluesky_publish_draft` - Publish previously created drafts as threads
- `bluesky_delete_draft` - Delete draft posts
- `bluesky_list_drafts` - List available drafts
- `bluesky_get_draft` - Get a specific draft post
- `bluesky_edit_post` - Edit an existing post
- `bluesky_delete_post` - Delete a post

### Engagement
- `bluesky_like` - Like a post
- `bluesky_delete_like` - Remove a like
- `bluesky_repost` - Repost someone else's post
- `bluesky_delete_repost` - Remove a repost
- `bluesky_quote_post` - Quote another post with commentary
- `bluesky_get_likes` - Get likes for a specific post

### Account Management
- `bluesky_follow` - Follow a user
- `bluesky_delete_follow` - Unfollow a user
- `bluesky_update_bio` - Update profile bio
- `bluesky_update_display_name` - Change display name
- `bluesky_update_external_url` - Update profile URL

### Content Discovery
- `bluesky_search_posts` - Search for posts with filtering options
- `bluesky_get_timeline` - Get user timeline
- `bluesky_get_post_thread` - Get a complete conversation thread
- `bluesky_get_profile` - Get a user's profile information
- `bluesky_get_followers` - Get a user's followers
- `bluesky_get_follows` - Get accounts a user follows

## Notable Missing Functionality

Compared to the full Bluesky API, these important features appear to be missing or limited in our MCP:

### Discovery
- **Trending Topics/Hashtags** - Limited access to trending content
  - The `bluesky_get_timeline` function with `algorithm="trending"` or `algorithm="popular"` does return trending content but doesn't provide explicit topic/hashtag data
  - No API for directly accessing the top trending hashtags list that exists in apps like Graysky
- **Custom Feed Discovery** - Limited ability to discover and browse popular custom feeds
  - No built-in function to list available custom feeds
  - Can access specific feeds using URIs like `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot` via `bluesky_get_timeline`
- **Suggested Follows** - No API for suggested accounts to follow

### Content
- **Custom Feeds** - Cannot create or manage custom feeds
- **Lists** - No API for creating or managing lists
- **Moderation Features** - Limited access to moderation tools
- **Media Upload** - No direct function for uploading images

### Analysis
- **Post Analytics** - No access to view counts or engagement analytics
- **Notifications** - Cannot access notification stream

## Potential Workarounds

### For Trending Topics
- Use `bluesky_get_timeline` with `algorithm="trending"` or `algorithm="popular"` to access current trending content
- Search for posts mentioning "trending hashtags" using `bluesky_search_posts` to find users sharing trending topics
- Monitor popular accounts like `@🤖 Bip-bop the Bot 🇷🇺` that regularly post trending hashtag lists

### For Custom Feed Access
- Access well-known custom feeds directly using their URIs:
  - What's Hot: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot`
  - What's Hot Classic: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic`
  - Mutuals: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/mutuals`
  - Best of Follows: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/best-of-follows`
  - Popular With Friends: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/with-friends`
  - Bluesky Team: `at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/bsky-team`
- Search for posts discussing specific feeds to discover new ones

### For Analytics
- Manually track engagement metrics (likes, reposts) on our posts using `bluesky_get_likes`
- Use `bluesky_get_post_thread` to analyze replies and conversation threads

## Recommendations

1. **Regular API Testing** - Periodically test the MCP against the official Bluesky API to identify new endpoints and features. The full API documentation can be found at https://docs.bsky.app/docs/tutorials/viewing-feeds.

2. **Feature Requests** - Identify high-priority missing features and request additions to the MCP, especially custom feed discovery and creation capabilities.

3. **Custom Analytics** - Build external tracking for our posts to compensate for missing analytics. Consider storing engagement metrics and trends in our own database.

4. **Community Monitoring** - Regularly use `bluesky_search_posts` to monitor relevant terms and build our own trend analysis.

5. **Third-Party Tools Research** - Investigate third-party tools that offer additional functionality, such as:
   - BlueSkyFeedCreator.com - For creating and maintaining custom feeds
   - deck.blue - For embedding hyperlinks and scheduling posts
   - Graysky (iOS app) - Features in-app translation and Trending Topics

6. **Custom Feed Collection** - Maintain a collection of useful custom feed URIs we discover in separate documentation for easy reference and sharing among our agents.

---

*Document created April 28, 2025 by phr34ky-c for the art.ifi.sh project*