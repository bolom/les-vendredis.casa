---
name: instagram-publisher
description: Publish photos from Les Vendredis to the Instagram account lesvendredis.casa using the official Meta Instagram API. Use when posting a public site image to Instagram, drafting captions for Instagram, validating Meta API prerequisites, or automating Instagram feed publishing. Covers professional account setup, token safety, image container creation, media publishing, and post verification.
---

# Instagram Publisher

Use this skill to publish Les Vendredis images to Instagram through the official Meta Instagram API.

## Requirements

- Instagram account must be Professional: Business or Creator.
- Meta Developer app must have Instagram API access.
- Required scope for publishing: `instagram_business_content_publish`.
- Required basic scope: `instagram_business_basic`.
- Media must be publicly reachable by URL before publishing. Local files cannot be uploaded directly.
- Never commit access tokens. Use environment variables only.

## Token Safety

Before running any command:

- Check `git status --short`; do not stage `.env`, token files, screenshots containing tokens, or logs with tokens.
- Prefer shell environment variables:
  - `IG_USER_ID`
  - `IG_ACCESS_TOKEN`
  - optional `META_GRAPH_VERSION`, for example `v24.0`
- If a command output contains a token, do not paste it back to the user.

## Standard Workflow

1. Confirm the image is already deployed and public:

   ```bash
   curl -I https://lesvendredis.casa/public/images/example.webp
   ```

   It must return `200` and an image `content-type`.

2. Draft a short caption in the Les Vendredis voice:

   - simple, concrete, first-person plural if needed;
   - mention Sainte-Luce or Martinique only when relevant;
   - keep hashtags restrained;
   - do not over-explain the place.

3. Publish with the bundled script:

   ```bash
   IG_USER_ID=... IG_ACCESS_TOKEN=... \
   python3 skills/instagram-publisher/scripts/publish_photo.py \
     --image-url "https://lesvendredis.casa/public/images/example.webp" \
     --caption "Mai donne. On prend soin de ce qu'on reçoit."
   ```

4. Verify the script returns a published media `id`.

## Script Behavior

`scripts/publish_photo.py` performs the official two-step content publishing flow:

1. `POST /{ig-user-id}/media` with `image_url` and `caption`.
2. `POST /{ig-user-id}/media_publish` with the returned `creation_id`.

Use `--dry-run` to validate inputs without calling Meta.

## Common Failure Modes

- `image_url` is not public: deploy the image first and verify with `curl -I`.
- Account is personal: switch to Professional.
- Missing permission: regenerate token with `instagram_business_content_publish`.
- Expired token: refresh or regenerate token.
- Container expired: containers are temporary; create a new one and publish promptly.

## Scope Boundaries

This skill posts single feed images. For carousels, Reels, or Stories, adapt the same container/publish flow but confirm current Meta parameters first from official Meta documentation.
