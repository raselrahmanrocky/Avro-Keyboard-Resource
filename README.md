# Avro Keyboard Resource

**[বাংলা](#বাংলা)** | **[English](#english)**

---

## বাংলা

মূল অ্যাপ ইনস্টল না করে বা ভুলবশত ফাইল ডিলিট হয়ে গেলে — ANSI ম্যাপিং, কীবোর্ড
লেআউট, ফন্ট, স্কিন ও ডকুমেন্ট এখান থেকে ডাউনলোড করে ফিরিয়ে আনা যাবে।

### কীভাবে ব্যবহার করবেন

**উপায় ১ — অ্যাপের ভেতর থেকে (সহজতম)**

Avro Keyboard-এর ট্রে মেনু / ANSI encoding মেনুর **More Options → Download
More Resources...** এ গিয়ে ক্যাটাগরি থেকে ফাইল বেছে ডাউনলোড করুন। অ্যাপই
সঠিক ফোল্ডারে সরাসরি সেট করে দেবে — ANSI ম্যাপিং ও স্কিন সাথে সাথেই কাজ করে,
ফন্ট রেজিস্টার হয়ে যায়, রিস্টার্ট লাগে না।

**উপায় ২ — ম্যানুয়ালি**

ফাইল ডাউনলোড করে নিচের ফোল্ডারগুলোতে কপি করুন
(`C:\ProgramData\Avro Keyboard\` — পোর্টেবল ভার্সনে এক্সে ফোল্ডারে):

| ফাইল | কপি করুন এখানে |
|---|---|
| `AnsiMapping\*.AvroEnco` | `AnsiMapping\` |
| `KeyboardLayouts\*.avrolayout` | `Keyboard Layouts\` |
| `Fonts\*.ttf` / `*.otf` | রাইট-ক্লিক → **Install** (বা উইন্ডোজ ফন্ট ফোল্ডারে) |
| `Skins\*.avroskin` | `Skin\` |
| `Docs\*` | যেকোনো জায়গায় — খুলে পড়ুন |

### ক্যাটাগরি

| ফোল্ডার | কী আছে | ফরম্যাট |
|---|---|---|
| `AnsiMapping/` | ANSI encoding ম্যাপিং (V1–V4) | `.AvroEnco` (encrypted container) |
| `KeyboardLayouts/` | ফিক্সড কীবোর্ড লেআউট (Avro Easy, Bijoy, Probhat...) | `.avrolayout` |
| `Fonts/` | Kalpurush, Siyam Rupali + ANSI ভার্সন | `.ttf` / `.otf` |
| `Skins/` | অন-স্ক্রিন কীবোর্ড স্কিন | `.avroskin` |
| `Docs/` | ইউজার গাইড (PDF/HTML) | `.pdf` / `.htm` |

`index.json` হলো মেশিন-রিডেবল ক্যাটালগ — অ্যাপ এটিই পড়ে। প্রতিটি এন্ট্রিতে
`sha256` ও `size` থাকে, ডাউনলোডের পর যাচাই করা হয়। **হাতে করে `index.json`
ছুঁয়ে লেখবেন না।**

### নতুন ফাইল যোগ করবেন (প্লাগ অ্যান্ড প্লে)

সঠিক ফোল্ডারে ফাইলটা যোগ করে push করুন (git অথবা GitHub ওয়েব UI) — এর বাইরে
কিছুই করতে হবে না। GitHub Actions অটো `index.json` রিজেনারেট করে, আর কয়েক
মিনিটের মধ্যে অ্যাপের **Download Resources**-এ ফাইলটা চলে আসবে।

| ফোল্ডার | এক্সটেনশন | টাইপ |
|---|---|---|
| `AnsiMapping/` | `.AvroEnco` | ANSI mapping |
| `KeyboardLayouts/` | `.avrolayout` | কীবোর্ড লেআউট |
| `Fonts/` | `.ttf`, `.otf` | ফন্ট |
| `Skins/` | `.avroskin` | স্কিন |
| `Docs/` | `.pdf`, `.htm`, `.html` | ডকুমেন্ট |

* নতুন টপ-লেভেল ফোল্ডার বানালেও চলবে — সেটা অ্যাপে নতুন ক্যাটাগরি হিসেবে
  দেখাবে (শুধু সাপোর্টেড এক্সটেনশনের ফাইলই তালিকাভুক্ত হবে)।
* English বর্ণনা/ভার্সন দিতে চাইলে ফাইলের পাশে একটা `<নাম>.meta.json` সাইডকার
  দিন — `{"description": "...", "version": "..."}`। সাইডকার থাকলে সেটাই
  জিতবে, না থাকলে আগের description, তাও না থাকলে ফাইলনাম।
* এই তালিকার বাইরের এক্সটেনশন (`.zip` ইত্যাদি) এখন স্কিপ হবে — দরকার হলে
  অ্যাপের কোড আপগ্রেড করে যোগ করা হবে।

### মেইনটেইনারদের জন্য

`assets\` থেকে পাঁচটা ক্যাটাগরি ফোল্ডার রিসিংক (মিরর) করতে মেইন Avro-Keyboard
রিপো থেকে:

```powershell
powershell -ExecutionPolicy Bypass -File tools\resource-sync\generate-resource-index.ps1
```

স্ক্রিপ্টটি ক্যাটাগরি ফোল্ডার মিরর করার আগে সতর্কতা দেয়, `*.meta.json`
সাইডকার সংরক্ষণ করে, ANSI metadata থেকে sidecar বানায় — এবং `index.json`
রিজেনারেট করে এই রিপোর নিজের স্ক্যানারের মাধ্যমে। এরপর কমিট ও push করুন।

Actions না চললে স্ক্যানারটাই লোকালি চালিয়ে দিন — সেটা শুধু `index.json` লেখে:

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\generate-index.ps1
```

### লাইসেন্স

কোড ও ম্যাপিং ফাইলগুলো [Mozilla Public License 2.0](LICENSE)। ফন্টগুলো তাদের
নিজ নিজ লাইসেন্স অনুযায়ী বিতরণ করা হয় — দেখুন [`licenses/`](licenses/)।

---

## English

A downloadable resource pack for [Avro Keyboard](https://github.com/omicro/Avro-Keyboard):
ANSI mappings, keyboard layouts, fonts, skins and documentation — so users can
restore or add resources without reinstalling the whole application.

### How to use

**Method 1 — In-app (easiest)**

Open **More Options → Download More Resources...** in the tray / ANSI encoding
menu of Avro Keyboard, pick a category and download. The app installs every
file into the right folder automatically — ANSI mappings and skins are picked
up immediately, fonts register for the current user, no restart needed.

**Method 2 — Manually**

Download a file and copy it into the matching folder under
`C:\ProgramData\Avro Keyboard\` (or beside the .exe for the portable build):

| File | Copy it here |
|---|---|
| `AnsiMapping\*.AvroEnco` | `AnsiMapping\` |
| `KeyboardLayouts\*.avrolayout` | `Keyboard Layouts\` |
| `Fonts\*.ttf` / `*.otf` | Right-click → **Install** (or the Windows Fonts folder) |
| `Skins\*.avroskin` | `Skin\` |
| `Docs\*` | Anywhere — just open and read |

### Categories

| Folder | What's inside | Format |
|---|---|---|
| `AnsiMapping/` | ANSI encoding mappings (V1–V4) | `.AvroEnco` (encrypted container) |
| `KeyboardLayouts/` | Fixed keyboard layouts (Avro Easy, Bijoy, Probhat...) | `.avrolayout` |
| `Fonts/` | Kalpurush, Siyam Rupali + ANSI variants | `.ttf` / `.otf` |
| `Skins/` | On-screen keyboard skins | `.avroskin` |
| `Docs/` | User guides (PDF/HTML) | `.pdf` / `.htm` |

`index.json` is the machine-readable catalog consumed by the in-app downloader;
every entry carries `sha256` + `size` for post-download verification.
**Never edit `index.json` by hand.**

### Adding a resource (plug & play)

Drop a file into the right folder and push (git or the GitHub web UI) — that is
all. GitHub Actions regenerates `index.json` automatically and the file shows
up in Avro Keyboard's **Download Resources** within minutes.

| Folder | Extension | Type |
|---|---|---|
| `AnsiMapping/` | `.AvroEnco` | ANSI mapping |
| `KeyboardLayouts/` | `.avrolayout` | keyboard layout |
| `Fonts/` | `.ttf`, `.otf` | font |
| `Skins/` | `.avroskin` | skin |
| `Docs/` | `.pdf`, `.htm`, `.html` | document |

* A brand-new top-level folder also works — it appears as a new category in the
  app (only files with supported extensions are listed).
* For an English description/version, add a `<name>.meta.json` sidecar next to
  the file — `{"description": "...", "version": "..."}`. The sidecar wins when
  present, otherwise the previous description, otherwise the filename.
* Extensions outside this list (`.zip` etc.) are skipped for now — the app code
  can be upgraded later to support new types.

### For maintainers

To re-sync the five category folders from `assets\`, run from the main
Avro-Keyboard repository:

```powershell
powershell -ExecutionPolicy Bypass -File tools\resource-sync\generate-resource-index.ps1
```

The script warns before wiping the category folders, preserves `*.meta.json`
sidecars, converts ANSI metadata into sidecars — and regenerates `index.json`
through this repository's own scanner. Then commit and push.

If Actions is unavailable, run the scanner locally — it only writes
`index.json`:

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\generate-index.ps1
```

### License

Code and mapping files are licensed under [MPL 2.0](LICENSE); fonts under
their own terms — see [`licenses/`](licenses/).
