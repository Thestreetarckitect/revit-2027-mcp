# Ebook Lead Magnet Flow

Free ebook on Stan Store → Skool community. A free product on Stan Store still
records as a **$0 order**, and that order is the trigger for the whole chain.

Flow at a glance:

```
ManyChat (keyword: AUTOMATE) ──► Stan Store ($0 order) ──► Zapier ──► Gmail
        front door                free product          the bridge   backup email
                                        │
                                        └──► post-checkout redirect ──► Skool invite
```

---

## 1. Stan Store setup

- Set the ebook up as a **free product**, price set to `0`.
- Turn on **email collection at checkout** if it is not already on.
- Check product settings for a **post-checkout redirect** field. If Stan Store
  has one, point it directly at your Skool invite link. That alone might replace
  half of what Zapier and Gmail are doing. Check this before building anything
  else — it may make the redirect the primary path and the email the backup.

## 2. Zapier — the bridge

Stan Store does not talk to Gmail on its own. Zapier sits in between.

- **Trigger:** Stan Store → New Order (or New Sale; naming varies by Zapier version).
- **Filter:** only continue if the product name matches your ebook, so this does
  not fire for other things you sell later.
- **Action:** Gmail → Send Email, using the buyer's email from the trigger as
  the recipient. Paste the template from Section 4 into the Gmail action body
  and wire the bracketed fields to Stan Store merge fields.
- **Test with a real $0 order before trusting it live.** Some platforms exclude
  free orders from their "sale" trigger and only fire on paid ones. You will not
  know until you run one through.

## 3. ManyChat — the front door

This is what actually gets people to Stan Store in the first place.

- **Keyword:** `AUTOMATE`. `STARTER` and `BLUEPRINT` are already taken by
  existing flows. Swap it in ManyChat in one click if you want something else.
- Comment or DM `AUTOMATE` → public comment reply, then a DM with the Stan Store link.
- **Tag** the contact `ebookrequested` inside ManyChat so you can track who came
  in through this specific flow.

## 4. The email itself

Saved to Gmail drafts (subject: *Your [Ebook Name] guide plus your Skool
invite*). Copy it into the Zapier Gmail action and swap the bracketed
placeholders for real values or Zapier merge fields before turning it on.

**Subject:** `Your [Ebook Name] guide plus your Skool invite`

**Body:**

```
Hey [First Name],

Your free guide is unlocked. Check your Stan Store confirmation for the download link.

Here is your next move. Join the free Skool community where I break down the exact
BIM and AI workflows I use every week.

[SKOOL INVITE LINK]

Inside you get:
- Weekly workflow breakdowns you will not see on TikTok
- Direct access to ask questions on Revit, Navisworks, and AI tool setups
- First access to new guides before they go public

Comment BLUEPRINT on my latest video if you are ready to go deeper after this.

See you inside,
[Your Name]
TheStreetArckitect
```

**Which one does the real work?** If Stan Store's redirect can send buyers
straight to Skool, that redirect is the main job and the email is the backup —
it catches anyone who closes the tab before clicking through. Build both, but
know which is doing the work.

---

## Placeholders to swap before going live

| Placeholder        | Replace with                                      |
| ------------------ | ------------------------------------------------- |
| `[Ebook Name]`     | Real product name (static or Stan Store field)    |
| `[First Name]`     | Zapier merge field from the Stan Store trigger    |
| `[SKOOL INVITE LINK]` | Your Skool community invite URL                |
| `[Your Name]`      | Your name                                         |

## Go-live checklist

- [ ] Stan Store product is free (`$0`) and email collection is on
- [ ] Post-checkout redirect set to Skool invite (if the field exists)
- [ ] Zapier trigger fires on a real `$0` test order
- [ ] Zapier filter matches only this ebook's product name
- [ ] Gmail action uses buyer email + template with merge fields wired
- [ ] ManyChat `AUTOMATE` keyword posts comment reply + DM with Stan link
- [ ] ManyChat tags contact `ebookrequested`
- [ ] End-to-end test: comment `AUTOMATE` → DM → checkout → email + redirect land
