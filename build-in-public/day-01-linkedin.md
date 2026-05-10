# Day 1 — LinkedIn Post

**Post date:** 2026-05-10

---

## Post Content

**I started building Feddan today — a smart farm assistant for Egyptian farmers — and I'm doing it entirely in public.**

Here's what I built in one day, and why I think this matters.

---

**The problem:**

Egypt has over 4 million smallholder farmers. Most of them irrigate by habit ("it's Tuesday, I irrigate") instead of by need. That wastes 30–40% of their water, reduces crop yield, and costs money they can't afford to lose.

The information to fix this already exists — FAO crop coefficients, NASA weather satellites, decades of agronomy research. But it's all locked inside academic papers and expensive consultants.

---

**The solution:**

فدان (Feddan, the Egyptian unit of land area) delivers one simple thing every morning:

> "ري الطماطم اليوم — الطلب المائي 5.2 مم"
> "Water your tomatoes today — water demand 5.2mm"

The app calculates this using:
• Real weather data from NASA POWER (free, no API key required)
• FAO-56 crop coefficients matched to the current growth stage
• ETc = ET₀ × Kc — the global standard for crop water demand

It sends this as a push notification at 6am Cairo time. The farmer taps "done" when they irrigate. That's it.

---

**What I built today:**

✅ Flutter app (Android + iOS, Arabic-first RTL, English toggle)
✅ BLoC architecture with Clean Architecture layers
✅ Firebase Auth with phone OTP — no email, no app store login required
✅ Farm profile with GPS location + crop selection + planting date
✅ Daily task engine in TypeScript (Cloud Functions)
✅ NASA POWER API integration (weather → irrigation decision)
✅ FAO-56 Kc values for 10 crops (tomatoes, potatoes, watermelon, etc.)
✅ FCM push notifications — daily digest per farm
✅ Firestore security rules in production

**Total budget spent so far: $0. Total budget available: $100.**

---

**Why build in public?**

Because "building in public" is the cheapest distribution strategy a pre-seed founder has. Every post is a product demo. Every follower is a potential early adopter or investor. Every critique makes the product better.

I'm documenting every decision, every line of code, and every farmer conversation.

---

**What's next:**

Week 1 ✅ Core infrastructure
Week 2 — Weather widget + maps + TestFlight beta
Week 3 — Beta test with real Egyptian farmers
Week 4 — Play Store submission

If you know farmers, agronomists, or agricultural NGOs in Egypt or the Middle East, I'd love an introduction.

If you're a Flutter or Firebase developer who wants to contribute, the repo is open.

**GitHub:** github.com/ahmedfar/feddan-mobile

#BuildInPublic #Flutter #Firebase #AgriTech #Egypt #StartupLife #MobileApp

---

## Posting Instructions

1. Post as a native LinkedIn article or as a long-form post (no link preview needed)
2. Add 2–3 screenshots: splash screen, farm profile page, home task list
3. Tag relevant people: Flutter community accounts, AgriTech accounts
4. Post Tuesday or Wednesday, 9–11am Cairo time
5. First comment: drop the GitHub link again for visibility
