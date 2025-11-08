# Deployment Guide

## ⚠️ IMPORTANT: Static Hosting Won't Work

**GitHub Pages, Vercel, and Cloudflare Pages are for STATIC sites only.**

Your app is a **Sinatra web application** that needs:
- A running server
- File uploads (POST requests)
- Server-side processing
- File system access

These don't work on static hosting!

---

## 🚀 Best Free Options for Sinatra Apps

### 1. **Render.com** (Easiest - Recommended) ⭐

**Free Tier:**
- 750 hours/month free
- Sleeps after 15 min inactivity (wakes on request)
- Perfect for demos/portfolios

**Steps:**
1. Push code to GitHub
2. Go to [render.com](https://render.com)
3. Connect GitHub repo
4. New Web Service → Ruby
5. Build: `bundle install`
6. Start: `bundle exec rackup config.ru -p $PORT`
7. Done! Get a URL like `https://your-app.onrender.com`

**Pros:** Easiest, free, auto-deploys from GitHub
**Cons:** Sleeps after inactivity (slow first request)

---

### 2. **Railway.app** (Good Alternative)

**Free Tier:**
- $5 credit/month
- No sleep (always running)
- Auto-deploys from GitHub

**Steps:**
1. Push to GitHub
2. Go to [railway.app](https://railway.app)
3. New Project → Deploy from GitHub
4. Select repo → Auto-detects Ruby
5. Deploy!

**Pros:** Never sleeps, fast, auto-deploy
**Cons:** $5/month credit (runs out if you use too much)

---

### 3. **Fly.io** (More Control)

**Free Tier:**
- 3 shared-cpu VMs
- 160GB outbound data/month
- Good for production

**Pros:** More control, fast, good docs
**Cons:** More setup, CLI required

---

## 🖥️ Deploy to Your Own Server

### Option A: Manual Deploy

1. **On your server:**
   ```bash
   git clone YOUR_GITHUB_REPO_URL
   cd RubyTranscribe
   bundle install
   ```

2. **Run with systemd (always running):**
   Create `/etc/systemd/system/static-site-gen.service`:
   ```ini
   [Unit]
   Description=Static Site Generator
   After=network.target

   [Service]
   Type=simple
   User=your-username
   WorkingDirectory=/path/to/RubyTranscribe
   ExecStart=/usr/bin/bundle exec rackup config.ru -p 4567
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. **Start service:**
   ```bash
   sudo systemctl enable static-site-gen
   sudo systemctl start static-site-gen
   ```

### Option B: Auto-Deploy from GitHub

1. **Set up GitHub Secrets:**
   - Go to repo → Settings → Secrets
   - Add: `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`

2. **GitHub Actions will auto-deploy** when you push to `main`

3. **On your server, clone repo first:**
   ```bash
   git clone YOUR_REPO
   cd RubyTranscribe
   bundle install
   ```

---

## 📊 Comparison Table

| Service | Free? | Sleeps? | Auto-Deploy? | Ease |
|---------|-------|---------|--------------|------|
| **Render** | ✅ Yes | ⏸️ Yes | ✅ Yes | ⭐⭐⭐⭐⭐ |
| **Railway** | ✅ $5 credit | ❌ No | ✅ Yes | ⭐⭐⭐⭐ |
| **Fly.io** | ✅ Yes | ❌ No | ✅ Yes | ⭐⭐⭐ |
| **Your Server** | ✅ Free | ❌ No | ✅ Yes (with Actions) | ⭐⭐ |

---

## 🎯 My Recommendation

**For a demo/portfolio:** Use **Render.com** - it's the easiest!

**For production/always-on:** Use **Railway** or your own server.

---

## Quick Start: Render.com

1. Push code to GitHub
2. Go to render.com → New Web Service
3. Connect GitHub
4. Settings:
   - Build: `bundle install`
   - Start: `bundle exec rackup config.ru -p $PORT`
5. Deploy!
6. Done! 🎉

