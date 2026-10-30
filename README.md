# Chitra AI

កម្មវិធី Flutter UI demo សម្រាប់បង្កើតរូបភាពពី prompt ជាអត្ថបទ និងរចនាប័ទ្មដែលបានជ្រើស។ រូប preview ប្រើ `SampleArtwork` ក្នុងមូលដ្ឋាន។ មិនទាន់ភ្ជាប់ image model API, backend, authentication ពិត ឬ cloud storage ទេ។ មិនមាន package ថ្មីត្រូវបានបន្ថែម។

## អេក្រង់ និងមុខងារ

- **Intro 1–3** បង្ហាញការណែនាំ; Skip ឬ Get started បើក Login/Sign up។
- **Login/Sign up** ផ្ទៀងផ្ទាត់ email, password យ៉ាងតិច ៨ តួអក្សរ និងឈ្មោះពេល Sign up។ Forgot password ជាទំព័រដាច់ដោយឡែក។ Authentication ទាំងនេះជាការសាកល្បង UI ក្នុងមូលដ្ឋាន។
- **Create** ទទួល prompt ធម្មតា, អនុញ្ញាត Improve with AI និងរចនាប័ទ្ម Photorealistic, Anime, Cyberpunk, Watercolor, 3D។ ការកែលម្អ prompt ប្រើច្បាប់ក្នុងមូលដ្ឋាន និងបង្ហាញអត្ថបទដែលបានកែ ដើម្បីឲ្យអ្នកប្រើអាចកែបន្ត។
- **Generating** បង្ហាញដំណាក់កាលពី `ImageService` (Checking, Creating, Saving) ហើយបង្ហាញទំព័រកំហុសតាមប្រភេទ (busy, rate limit, blocked, timeout, offline)។ បិទមុនចប់ នឹងមិនបន្ថែមរូបទៅ Library។
- **Result** (ទំព័រតែមួយ ទាំងពេលទើបបង្កើត និងពេលបើកពី Library) បង្ហាញ sample preview, prompt/style, Save, Download, Share និង Regenerate។ Edit, Image details និង Delete ស្ថិតក្នុងម៉ឺនុយ ⋮។ Save ប្ដូរស្ថានភាពក្នុង app។ Download និង Share បច្ចុប្បន្នបង្ហាញសារ coming soon ព្រោះមិនមាន image bytes ឬ platform integration។
- **Explore / Library / Profile** អនុញ្ញាតជ្រើស sample prompt, មើល history/saved, កែឈ្មោះ/username និងប្ដូរ appearance។ History និង saved រក្សាទុកក្នុង memory រហូតដល់បិទ app ឬ Log out។
- **Help and support, Appearance, Change email, Change password, Forgot password និង Contact support form** មានទំព័រផ្ទាល់ខ្លួន។

## រចនាសម្ព័ន្ធកូដ

- `lib/repair/app.dart` កំណត់ app និង Material 3 themes។
- `lib/repair/theme_state.dart` រក្សា Light/Dark/System mode។
- `lib/repair/artwork_store.dart` ជា ValueNotifier store សម្រាប់ history, saved និង profile។
- `lib/repair/models/artwork.dart` ជា model នៃ prompt, style, timestamp និង seed។
- `lib/repair/screens/auth_screen.dart` មាន onboarding និង login/signup flow។
- `lib/repair/screens/home_screen.dart` មាន Create, Explore, Library, Profile និង navigation handlers។
- `lib/repair/screens/account_pages.dart` មាន settings, help, support form, forgot password និង edit profile។
- `lib/repair/screens/generation_pages.dart` មាន Generating និងទំព័រកំហុសតាមប្រភេទ។
- `lib/repair/screens/result_screen.dart` មាន Result, Image details, Delete និង Save/Download/Share action row។
- `lib/repair/services/image_service.dart` ជា `ImageService` (improvePrompt, generateImage) ជាមួយ `DemoImageService`។
- `lib/repair/styles.dart` មានបញ្ជី style និងប្រវែង prompt អតិបរមា។
- `lib/repair/widgets/sample_artwork.dart` បង្ហាញរូបគំរូក្នុងមូលដ្ឋាន។

## Prompt wording

Prompt `a fox in a library` បញ្ជាក់តែប្រធានបទ។ `a red fox reading a book in a cozy library` បន្ថែមពណ៌, សកម្មភាព និងទីតាំង ដើម្បីឲ្យគំនិតច្បាស់។ `warm lamp light, soft shadows` កំណត់ពន្លឺ និងបរិយាកាស។ Style `watercolor` ណែនាំគែមទន់ និងពណ៌រាល; `cinematic lighting` ណែនាំ contrast ខ្លាំង។ ក្នុង demo នេះ prompt ត្រូវបានរក្សាទុក និងបង្ហាញជាមួយ preview ប៉ុណ្ណោះ; វាមិនបញ្ជូនទៅ model ពិតទេ។

## ពិនិត្យ project

ដំណើរការ `flutter analyze` និង `flutter test` ពី root project ដើម្បីពិនិត្យកូដ និង widget tests។

## Connecting the backend

All screens talk to `ImageService` (`lib/repair/services/image_service.dart`). To connect your FastAPI backend:

1. Create `ApiImageService implements ImageService`. `improvePrompt` calls `POST /api/ai/enhance-prompt` and `generateImage` calls `POST /api/ai/generate-image`.
2. Throw `ImageServiceException` for each failure: 429 as `rateLimited` (use Retry-After), 503 as `busy`, a safety-filter rejection as `blocked`, a request timeout as `timeout`, no connection as `offline`, anything else as `unknown`.
3. Return the image address in `GeneratedImage(seed: ..., imageUrl: ...)`. The screens show it automatically.
4. Change the one line `ImageService imageService = DemoImageService();` to use `ApiImageService()`.

Try every error screen with the demo service by putting a tag in the idea: `[busy]`, `[limit]`, `[timeout]`, `[offline]` (each fails once, then works on Try again) or `[blocked]` (always blocked).

The style names must match the backend. Photorealistic, Anime and Cyberpunk exist; Watercolor and 3D need a style pack added.
