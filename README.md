# Avro Keyboard Resource

মূল অ্যাপ ইনস্টল না করে বা ভুলবশত ফাইল ডিলিট হয়ে গেলে — ANSI ম্যাপিং, কীবোর্ড লেআউট,
ফন্ট, স্কিন ও ডকুমেন্ট এখান থেকে ডাউনলোড করে ফিরিয়ে আনা যাবে।

A downloadable resource pack for [Avro Keyboard](https://github.com/omicro/Avro-Keyboard):
ANSI mappings, keyboard layouts, fonts, skins and documentation — so users can
restore or add resources without reinstalling the whole application.

---

## কীভাবে ব্যবহার করবেন / How to use

### উপায় ১ — অ্যাপের ভেতর থেকে (সহজতম) / Method 1 — In-app (easiest)

Avro Keyboard-এর ট্রে মেনু / ANSI encoding মেনুর **More Options → Download
More Resources...** এ গিয়ে ক্যাটাগরি থেকে ফাইল বেছে ডাউনলোড করুন। অ্যাপই
সঠিক ফোল্ডারে সরাসরি সেট করে দেবে।

Open **More Options → Download More Resources...** in the tray / ANSI encoding
menu of Avro Keyboard, pick a category and download. The app installs every
file into the right folder automatically.

### উপায় ২ — ম্যানুয়ালি / Method 2 — Manually

ফাইল ডাউনলোড করে নিচের ফোল্ডারগুলোতে কপি করুন
(`C:\ProgramData\Avro Keyboard\` — পোর্টেবল ভার্সনে এক্সে ফোল্ডারে):

| ফাইল | কপি করুন এখানে |
|---|---|
| `AnsiMapping\*.AvroEnco` | `AnsiMapping\` |
| `KeyboardLayouts\*.avrolayout` | `Keyboard Layouts\` |
| `Fonts\*.ttf` | রাইট-ক্লিক → **Install** (বা উইন্ডোজ ফন্ট ফোল্ডারে) |
| `Skins\*.avroskin` | `Skin\` |
| `Docs\*` | যেকোনো জায়গায় — খুলে পড়ুন |

Download a file and copy it into the matching folder under
`C:\ProgramData\Avro Keyboard\` (or beside the .exe for the portable build).
Fonts: right-click → **Install**. Avro picks up new ANSI mappings and skins
automatically (folder watcher) — no restart needed.

---

## ক্যাটাগরি / Categories

| ফোল্ডার | কী আছে | ফরম্যাট |
|---|---|---|
| `AnsiMapping/` | ANSI encoding ম্যাপিং (V1–V4) | `.AvroEnco` (encrypted container) |
| `KeyboardLayouts/` | ফিক্সড কীবোর্ড লেআউট (Avro Easy, Bijoy, Probhat...) | `.avrolayout` |
| `Fonts/` | Kalpurush, Siyam Rupali + ANSI ভার্সন | `.ttf` |
| `Skins/` | অন-স্ক্রিন কীবোর্ড স্কিন | `.avroskin` |
| `Docs/` | ইউজার গাইড (PDF/HTML) | `.pdf` / `.htm` |

`index.json` হলো মেশিন-রিডেবল ক্যাটালগ — অ্যাপ এটিই পড়ে। প্রতিটি এন্ট্রিতে
`sha256` ও `size` থাকে, ডাউনলোডের পর যাচাই করা হয়।

`index.json` is the machine-readable catalog consumed by the in-app downloader;
every entry carries `sha256` + `size` for post-download verification.

---

## মেইনটেইনারদের জন্য / For maintainers

রিসোর্সগুলো মূল রিপোর থেকে জেনারেট হয় — হাতে কপি করবেন না:

```powershell
# Avro-Keyboard রিপোর থেকে:
powershell -ExecutionPolicy Bypass -File tools\resource-sync\generate-resource-index.ps1
```

স্ক্রিপ্টটি `assets\` থেকে ফাইল সিঙ্ক করে, SHA-256 হিসাব করে এবং `index.json`
রিজেনারেট করে। এরপর এই রিপোতে কমিট ও push করুন।

---

## লাইসেন্স / License

কোড ও ম্যাপিং ফাইলগুলো [Mozilla Public License 2.0](LICENSE)।
ফন্টগুলো তাদের নিজ নিজ লাইসেন্স অনুযায়ী বিতরণ করা হয় — দেখুন
[`licenses/`](licenses/)।

Code and mapping files are licensed under [MPL 2.0](LICENSE); fonts under
their own terms — see [`licenses/`](licenses/).
