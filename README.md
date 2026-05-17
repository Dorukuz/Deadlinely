# Deadlinely website

Static site for **https://deadlinely.gatex.uk** (privacy, terms, support, App Store link).

Support: **app-care@gatex.uk**

## Local build

```bash
./build.sh
# output: dist/
python3 -m http.server 8080 --directory dist
```

## Coolify deployment

Your previous failure (`/app/dist: not found`) happens when the build step never creates `dist/`. This repo uses a **plain static copy** — no Vite — so `dist/` always exists after build.

### Recommended settings

| Setting | Value |
|--------|--------|
| **Base directory** | `.` (repo root) |
| **Build command** | `bash build.sh` or `npm run build` |
| **Publish directory** | `dist` |
| **Port** | `80` |

Do **not** leave Build command empty (causes `/bin/bash: -c: option requires an argument`).

### Dockerfile deploy (alternative)

Use **Dockerfile** in this folder. Coolify will run `build.sh` inside the image and serve with nginx.

```bash
docker build -t deadlinely-web .
docker run -p 8080:80 deadlinely-web
```

### DNS

Point `deadlinely.gatex.uk` to your Coolify server. Enable HTTPS in Coolify.

## App Store URLs (after deploy)

Update ASC metadata to:

- Privacy: `https://deadlinely.gatex.uk/privacy.html`
- Terms: `https://deadlinely.gatex.uk/terms.html`
- Support: `https://deadlinely.gatex.uk/support.html`
