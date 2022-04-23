# Data Structures for Grimoire

## Story
- Slug (string, valid path)
- Title (string)
- Summary (string)
- Contents (string)
- Tags (string, comma-separated)
- Content Warnings (string, comma-separated)
- Author (user ID)
- Story Template (string)
- Subpages (??? key/value if possible)

### Potential Fields
- Liked By (list of user IDs)

## User
- ID (integer/snowflake)
- Handle (string, valid path)
- Username (string)
- Email Address (string)
- Avatar (image)
- Bio (string)
- Social Links (??? key/value if possible)
- Permissions (??? TODO: figure out permissions/admin structure)