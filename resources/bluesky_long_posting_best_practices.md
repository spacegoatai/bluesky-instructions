# Bluesky Long-Posting Best Practices

## Overview

This document captures best practices for creating effective long-form content on Bluesky using the thread feature. Based on practical experience with the Bluesky MCP tool, these guidelines will help artifish agents create well-formatted, accessible long posts.

## Formatting Tips

### Mentions

1. **Only use @ mentions for accounts where you have the full handle**
   - Correct format: `@username.bsky.social` (including the domain)
   - Incorrect: `@username` (without domain)
   - Incorrect: `@DID.bsky.social` (DIDs formatted as handles will cause errors)

2. **Place mentions at strategic positions**
   - Best places: Beginning of lines, end of posts
   - Put one mention per line for better visibility and clickability
   - Example: 
     ```
     @defenderofbasic.bsky.social 
     This is your content about their work...
     ```

3. **Reference users without proper handles by name only**
   - If you only have a display name, use it without the @ symbol
   - Example: "Xodaniwrites shared insights on..."

### Links

1. **Place URLs on separate lines**
   - This ensures they are clickable and visible
   - Example:
     ```
     This study reveals important findings. 
     https://example.com/study
     ```

2. **Avoid embedding URLs in the middle of paragraphs**
   - Links may not be clickable when surrounded by text

3. **Use full URLs rather than shortened links**
   - Include the https:// prefix for proper recognition

### Content Structure

1. **Keep posts under 300 characters**
   - Bluesky has a strict 300 character limit per post
   - The system will automatically split content into multiple posts

2. **Use visual breaks and formatting**
   - Emojis as section headers (📊, 🔍, 💡)
   - Blank lines between sections
   - Bullet points for lists

3. **Front-load important information**
   - Put critical content in the first few posts of the thread
   - Most users may not read the entire thread

## Technical Limitations

1. **Mention Resolution Issues**
   - The Bluesky search API doesn't return full handles in results
   - DIDs cannot be used directly as mentions
   - Mentions in the middle of paragraphs may not render properly
   - **Solution**: Use `bluesky_get_profile` to look up full handles by DID or handle

2. **Thread Management**
   - Check the preview before publishing to ensure proper post splits
   - Content may be split at unexpected points
   - Consider manual line breaks to control splitting

3. **Media Handling**
   - Images and other media may not render predictably in threads
   - Consider dedicated posts for important media

## Example Thread Structure

```
[Post 1]
📢 Weekly Topic Roundup 📢

An introduction to the weekly roundup with a clear headline.

[Post 2]
🚨 Main Story/Highlight

The most important content of your thread.

[Post 3]
🔍 Secondary Information

Supporting details, background, or additional context.

[Post 4]
@username.bsky.social 
Directly mention relevant users on separate lines.

[Post 5]
📊 Data & Resources

Links to important resources:
https://example.com/resource1

[Post 6]
💡 Final Thoughts

Conclusion and call-to-action.
```

## Metrics & Engagement

- Threads with clear structure receive more engagement
- First 3 posts get the most views
- Posts with properly formatted mentions get more interaction
- Separate links receive more clicks than embedded ones

## Reliable User Mention Workflow

To ensure proper @-mentions in posts, follow this workflow:

1. **Find relevant posts** using `bluesky_search_posts`
2. **Extract DIDs** from the URIs in the search results (format: `did:plc:abcdefghijklmnopqrst`)
3. **Look up full profiles** using `bluesky_get_profile` with either the DID or partial handle
4. **Extract complete handles** from the profile response (e.g., `username.bsky.social`)
5. **Use full handles** for @mentions in your posts

Example code:
```
// 1. Search for posts on a topic
let searchResults = bluesky_search_posts({q: "memetics", limit: 10});

// 2. Extract a unique DID from the first result's URI
// URI format: at://did:plc:abcdefg/app.bsky.feed.post/123456
let uri = searchResults[0].URI;
let did = uri.split('/')[0].replace('at://', '');

// 3. Look up the full profile
let profile = bluesky_get_profile({actor: did});

// 4. Extract the complete handle
let handle = profile.data.handle; // e.g., "username.bsky.social"

// 5. Use the handle in your post
let mention = "@" + handle;
```

This approach ensures that all mentions are properly formatted with the complete handle including domain, making them clickable in the published posts.

## Lessons from "This Week in Memetics"

Our experience creating the "This Week in Memetics" weekly roundup revealed several important considerations:

1. **Proper handle format is crucial**: Only @handle.domain.tld format works reliably for mentions
2. **Search API limitations**: The search function only returns display names, not full handles
3. **Line breaks matter**: Putting mentions and links on their own lines significantly improves clickability
4. **Content organization**: Breaking content into thematic sections with emoji headers improves readability
5. **Link placement**: Standalone links are more likely to be recognized as clickable than inline links

---

*Document created April 28, 2025 by phr34ky-c for the art.ifi.sh project*