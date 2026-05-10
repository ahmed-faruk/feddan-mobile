# Day 1 — X/Twitter Thread

**Post date:** 2026-05-10
**Tags:** #BuildInPublic #Flutter #Firebase #Egypt #AgriTech #IndieHacker

---

## Tweet 1 — Hook (pin this)

I'm building an AI farm assistant for Egyptian farmers — in public — with a $100 budget.

Here's why, how, and what I've already shipped in one day. 🧵

#BuildInPublic #Flutter #AgriTech

---

## Tweet 2 — The Problem

Egypt has 4 million smallholder farmers.

Most of them don't know:
• When exactly to irrigate (wastes 30-40% of water)
• When to fertilize based on crop growth stage
• When disease risk is high (hot + humid = fungal outbreak)

They rely on guesswork or expensive agronomists.

---

## Tweet 3 — The Solution

فدان (Feddan) — named after the Egyptian unit of land area.

Every morning at 6am Cairo time, it:
1. Fetches real weather data from NASA (yes, NASA — free API)
2. Calculates exact crop water demand (FAO-56 formula)
3. Sends each farmer: "ري الطماطم اليوم — 5.2 مم"
   ("Water your tomatoes today — 5.2mm")

Arabic-first. Works on 3G.

---

## Tweet 4 — The Stack (and the budget)

Full Flutter app + Firebase backend, built for < $100 over 6 months:

✅ Flutter (Android + iOS)
✅ Firebase Auth — phone OTP login (no email needed)
✅ Firestore — farmer data
✅ Cloud Functions (TypeScript) — daily task engine
✅ NASA POWER API — weather data, completely free
✅ FCM — push notifications

Zero paid APIs. Zero guesswork.

---

## Tweet 5 — What I shipped on Day 1

In one session:

• Full BLoC + Clean Architecture Flutter scaffold
• Arabic-first RTL UI with English toggle (persisted to Hive)
• Phone OTP authentication flow (6-box PIN UI)
• Farm profile: GPS location + crop selection + planting date
• Task engine: NASA POWER → ETc = ET₀ × Kc → daily tasks
• FCM push notifications with daily digest
• Firestore security rules deployed to production

All code: github.com/ahmedfar/feddan-mobile

---

## Tweet 6 — The Math Behind It

The formula powering every irrigation alert:

ETc = ET₀ × Kc

• ET₀ = evapotranspiration from NASA POWER (free, no key!)
• Kc = FAO-56 crop coefficient (varies by growth stage)

For tomatoes mid-season in Egypt: Kc = 1.15
If ET₀ = 6mm/day → ETc = 6.9mm → "HIGH priority: irrigate today"

Agriculture science. Mobile app. Zero cost.

---

## Tweet 7 — What's Next (30-day plan)

Week 1: ✅ Core architecture + Firebase + Auth + Task Engine
Week 2: Weather widget + farm map + iOS TestFlight
Week 3: Beta test with 3 real Egyptian farmers (via WhatsApp)
Week 4: Play Store submission + Medium deep-dive post

Following along? Like + RT tweet 1 to help Egyptian farmers get better tools.

Reply with questions — building this 100% in the open.

---

## Tweet 8 — CTA

The repo is public. The budget is $100. The mission is real.

⭐ github.com/ahmedfar/feddan-mobile
📧 ahmed.faruk.ahmed@gmail.com

If you're a Flutter dev, Firebase expert, or know Egyptian farmers who'd benefit — let's talk.

#BuildInPublic #Flutter #Firebase #Egypt #AgriTech

---

## Posting Instructions

1. Post Tweet 1 first and pin it to your profile
2. Reply to Tweet 1 with Tweet 2, then reply to Tweet 2 with Tweet 3, etc. (threaded)
3. Attach a screenshot of the app (splash screen + home screen) to Tweet 5
4. Attach the formula image or a screenshot of the task engine code to Tweet 6
5. Post between 8–10am Cairo time (UTC+3) for maximum reach
6. Engage with every reply within the first hour
