# A.Vanderpuije Clothing: Go Live Checklist

Your Supabase URL and key are already wired into every page and admin.html.
Do these steps once, in order.

## 1. Run the database script (5 minutes)
1. Open your Supabase project, SQL Editor, New query.
2. Paste ALL of `supabase-schema.sql` and press Run. (If you ran an older version before,
   delete the old tables first: Table Editor, or ask me for a small upgrade script.)
3. Storage, New bucket named `product-images`, switch Public ON.
   (The script already adds the upload permissions for admins.)

## 2. Create your admin login and lock it down
1. Supabase, Authentication, Users, Add user, enter your email and a strong password.
2. IMPORTANT for security: Authentication, Sign In / Providers, turn OFF
   "Allow new users to sign up". Otherwise anyone could create an account.
3. Open `yourwebsite/admin.html` and sign in. You can now add and edit products
   (name, size, price, stock, photo, category, featured), manage orders and teach the chat assistant (FAQ tab).

## 3. Paystack (so you get paid)
1. Create your account at paystack.com (Ghana), finish business verification.
2. Settings, Preferences: add your SETTLEMENT bank or Mobile Money account. Paystack pays
   each sale into it automatically.
3. Settings, API Keys: copy the PUBLIC key (starts pk_test_ or pk_live_).
4. In every .html file, find `pk_test_REPLACE_WITH_YOUR_PAYSTACK_PUBLIC_KEY` and replace it
   (Find and Replace in all files). Use the test key first, place a test order, then switch to live.
5. Each new order shows in admin, Orders, as "awaiting confirmation". Match its reference with the
   payment in your Paystack dashboard, then set it to Paid. (Automatic verification needs a small
   server function: ask me and I will build it.)

## 4. Social links and email
In the script near the top of each page, edit `SOCIAL_LINKS`. Links left as "#" are hidden automatically.

## 5. Search (SEO)
Once you have your website address, send it to me: I will add the sitemap and absolute links.
Then: add the site to Google Search Console and create a Google Business Profile for both
stores. That is what makes you appear on Google Maps and local searches.

## App install
On Android/Chrome a banner offers "Install". On iPhone, Safari shows a tip: Share, Add to Home Screen.
(Install works only on the live https address.)

## Chat assistant
Admin, FAQ tab: add a question, the words customers may type, and your answer. Live in seconds.
