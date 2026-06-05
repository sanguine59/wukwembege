# Wukwembege — Feature List

> Food-stall event management app. Organizers run events and manage vendor stalls; vendors discover events and book their spot.

---

## Authentication

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Role selection | Onboarding | Choose organizer or vendor before proceeding | Both |
| Sign in | Login | Authenticate with email and password | Both |
| Role toggle on login | Login | Switch between organizer/vendor login context | Both |
| Password visibility toggle | Login | Show/hide password field | Both |
| Create account | Register | Register with name, business name, email and password | Both |
| Role selection on register | Register | Set account type at registration time | Both |
| Forgot password | Forgot Password | Send a reset link to the account email | Both |
| Reset confirmation | Forgot Password | Confirm reset email was sent, shows recipient address | Both |

---

## Organizer — Events

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Active events list | Organizer Home | Overview of all live and upcoming events with stall fill progress | Organizer |
| Archived events list | Organizer Home | Past events kept for reference and re-run planning | Organizer |
| KPI summary bar | Organizer Home | Shows active event count, confirmed stalls, and stalls awaiting review | Organizer |
| Create event | Event Edit (new) | Add a new event with all details | Organizer |
| Edit event | Event Edit (existing) | Update event name, type, date, time, location, city, capacity, fee, description, cover colour and glyph | Organizer |
| Event form validation | Event Edit | Blocks save if name, date or location are empty | Organizer |
| Delete event | Event Manage → menu | Permanently remove an event and all its stall records (confirmed with dialog) | Organizer |
| Share event | Event Manage → menu | Copy a shareable event link | Organizer |
| Event status badge | Event Manage | Visual indicator of live / upcoming / past state | Organizer |
| Stall fill progress | Event Manage | Bar showing confirmed stalls vs total capacity | Organizer |
| Quick stats | Event Manage | Confirmed count, pending count and stall fee at a glance | Organizer |

---

## Organizer — Stall Management

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Stall tabs | Event Manage | Filter stall list by Confirmed / Pending / All | Organizer |
| Add stall manually | Event Manage | Create a stall entry directly (name, owner, cuisine, spot, status) | Organizer |
| Edit stall | Event Manage → stall menu | Update stall details for an existing entry | Organizer |
| Approve application | Event Manage / Inbox | Confirm a pending stall, auto-assign next available spot | Organizer |
| Decline application | Event Manage / Inbox | Reject a pending stall application | Organizer |
| Remove stall | Event Manage → stall menu | Remove a vendor from the event entirely | Organizer |
| View vendor profile | Event Manage → stall menu | Open the vendor's profile from within the stall list | Organizer |
| Stall detail view | Stall Detail | Full vendor card with cuisine, rating, reviews, bio, contact and spot | Organizer |

---

## Vendor — Discovery

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Confirmed stalls overview | Vendor Home | Shows all upcoming confirmed spots with event, date, city and assigned pitch | Vendor |
| Pending applications overview | Vendor Home | Lists events where application is still under review | Vendor |
| Events completed counter | Vendor Home | KPI showing total past events attended | Vendor |
| Discover section | Vendor Home | Preview of 4 recommended open events with a browse-all link | Vendor |
| Browse feed | Browse | Full list of all upcoming and live events | Vendor |
| Search | Browse | Filter events by name or city in real time | Vendor |
| Status filter pills | Browse | Quick-filter feed to All / Live now / Upcoming | Vendor |
| Event type filter | Browse → filter sheet | Multi-select filter by event type (Night market, Food festival, etc.) | Vendor |
| City filter | Browse → filter sheet | Single-select filter by city | Vendor |
| Filter count badge | Browse | Shows number of active filters | Vendor |
| Clear filters | Browse | Reset all search and filter state in one tap | Vendor |
| Event detail view | Event Detail | Full event page: organizer info, date/time, location, fee, capacity bar, description and tags | Vendor |
| Stall availability bar | Event Detail | Visual progress showing spots taken vs total capacity with remaining count | Vendor |

---

## Vendor — Applications

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Apply for a stall | Event Detail | Submit an application with an optional note to the organizer | Vendor |
| Application note | Apply sheet | Free-text message included with the stall application | Vendor |
| Stall fee display | Apply sheet / Event Detail | Shows the cost due on approval before committing | Vendor |
| Join waitlist | Event Detail | Register interest when an event is at capacity | Vendor |
| Application pending state | Event Detail | Disables apply button and shows review status once applied | Vendor |
| Confirmed spot state | Event Detail | Shows assigned pitch and a withdraw option once approved | Vendor |
| Withdraw from event | Event Detail → withdraw dialog | Cancel a pending or confirmed participation (with confirmation) | Vendor |

---

## Inbox

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Unread / Earlier sections | Inbox | Separates new from previously seen notifications | Both |
| Mark all read | Inbox | Clear all unread indicators in one tap | Both |
| Unread badge on tab | Shell | Red dot on Inbox tab showing unread count | Both |
| Application notification | Inbox | Tells organizer a vendor applied to their event, with approve/decline/view actions | Organizer |
| Accepted notification | Inbox | Tells vendor their application was approved, with spot details | Vendor |
| Invite notification | Inbox | Organizer has personally invited vendor to apply, with apply/view actions | Vendor |
| Info notification | Inbox | General updates (spot confirmed, application under review, etc.) | Both |
| System notification | Inbox | Automated alerts (event fill percentage, application deadlines, fee reminders) | Both |
| Inline approve / decline | Inbox | Organizer can action pending applications directly from the notification | Organizer |
| Inline apply / view | Inbox | Vendor can jump to apply or view event directly from the notification | Vendor |
| Resolved state badge | Inbox | Shows outcome on already-actioned notifications (approved / declined) | Both |

---

## Profile & Account

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Profile card | Profile | Displays avatar, name, role label and account type badge | Both |
| Organizer metrics | Profile | Shows event count, vendor count and overall rating | Organizer |
| Vendor metrics | Profile | Shows rating, review count and events attended | Vendor |
| Edit profile | Edit Profile | Update business name, owner name, cuisine/role, bio, email and phone | Both |
| Profile avatar | Edit Profile | Placeholder for photo; tappable change-photo button | Both |
| Notification preferences | Settings | Per-channel toggles: new applications, status updates, email digest | Both |
| Privacy settings | Settings | Toggles for public profile visibility and location sharing | Both |
| Change password | Settings | Navigate to password update flow | Both |
| Payment methods | Settings | Navigate to payment management | Both |
| Delete account | Settings | Danger-styled option to permanently remove account | Both |
| App version | Settings | Displays current build version | Both |
| Role switching | Profile | "Preview the other side" — switches account between organizer and vendor while preserving identity | Both |
| Sign out | Profile | End the session and return to onboarding | Both |

---

## Navigation

| Feature | Page | Purpose | Role |
|---|---|---|---|
| Organizer tab bar | Shell | Three tabs: Events · Inbox · Profile | Organizer |
| Vendor tab bar | Shell | Four tabs: Home · Browse · Inbox · Profile | Vendor |
| Tab persistence | Shell | Each tab keeps its own navigation stack when switching | Both |
