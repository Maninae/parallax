# Contact Matching Bug Fix

The contact matching logic was failing for many contacts (especially iMessage handles with international dialing codes) because it relied on naive digit stripping and exact/suffix matching. We fixed this by integrating `PhoneNumberKit` to parse and format both handles and contact numbers into standardized E.164 formats (`+1...`, `+44...`, etc.), allowing for robust matching.

**Keywords**: contact matching, PhoneNumberKit, E.164, ContactStore, bug fix, international numbers
