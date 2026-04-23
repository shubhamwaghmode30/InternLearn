# Nexus

Nexus is a cross-platform Flutter learning app backed by Supabase.

It uses a structured learning path:

Subject -> Chapter -> Topic -> Subtopic -> Slides

Slides support three types:
- slide: markdown lesson content
- slide_mcq: multiple-choice interaction
- slide_match: match-the-pairs interaction

## Current Status

This documentation reflects the current codebase structure and behavior.

- App name: Nexus
- Package name: nexus
- Flutter routing: GoRouter + typed routes + ShellRoute
- Main tabs: Home, Search, Leaderboard, Progress, Profile
- Backend: Supabase Auth + PostgreSQL

## Tech Stack

- Flutter (Material 3)
- Supabase: supabase_flutter
- State: hooks_riverpod, flutter_riverpod, riverpod_annotation
- Routing: go_router, go_router_builder, go_router_paths
- Models/codegen: freezed, json_serializable, build_runner
- UI helpers: flutter_hooks, fl_chart, convex_bottom_bar, random_avatar
- Content rendering: flutter_markdown_plus
- Config: flutter_dotenv
- Logging: logger

## App Architecture

The app is organized by feature.

Each feature generally follows:
- data: models + riverpod providers
- services (or service): Supabase/data access logic
- presentation: screens + widgets

Top-level layout:

```text
lib/
  main.dart
  core/
    landing/
    providers/
    routes/
    singleton.dart
    theme/
    widgets/
  features/
    auth/
    content/
    leaderboard/
    profile/
    progress/
    search/
    slides/
```

## Navigation and Routing

Routing is configured in core routes with auth-aware redirects.

- Unauthenticated users are redirected to /login or /signup.
- Authenticated users are redirected away from auth routes to /.
- Shell navigation contains five tabs.

Primary shell tabs:
- /
- /search
- /leaderboard
- /progress
- /profile

Additional routes include:
- /login
- /signup
- content drilldown routes (chapters/topics/subtopics/slides)
- profile routes (edit profile, avatar picker, notifications, theme)

## Authentication Flow

1. App starts and loads .env.
2. Supabase initializes using SUPABASE_URL and SUPABASE_ANON_KEY.
3. Router redirect checks session state.
4. If not logged in, user goes to Login/Signup.
5. If logged in, user lands in shell tabs.

## Learning and Progress Flow

Content path:
- Subject -> Chapter -> Topic -> Subtopic -> Slide viewer

Slide viewer behavior:
- Merges content + MCQ + match slides by order.
- Content slides are always navigable.
- Interactive slides require completion before proceeding.
- On finish, completion action triggers RPC-based progress + XP updates.

Progress and XP are tied to Supabase objects and RPCs.

## Supabase Schema (High Level)

Core content tables:
- subject
- chapter
- topic
- subtopic
- slide
- slide_mcq
- slide_match

User progress/profile tables:
- user_profile
- user_subtopic_progress
- user_topic_progress
- user_chapter_progress

RPC/functions used by app include:
- complete_subtopic_and_award_xp
- get_my_progress_summary
- get_recent_completed_lessons
- get_weekly_subject_progress

Reference migration:
- supabase/migrations/20260416150811_remote_schema.sql

## Environment Setup

Create a .env file in project root:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Note:
- .env is loaded in app startup.
- .env is declared in assets in pubspec.yaml.

## Development Commands

Install dependencies:

```bash
flutter pub get
```

Run code generation:

```bash
dart run build_runner build -d
```

Watch code generation (recommended while editing providers/models/routes):

```bash
dart run build_runner watch -d
```

Run app:

```bash
flutter run
```

Analyze and test:

```bash
flutter analyze
flutter test
```

## Platform Support

Scaffolded for:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

## Troubleshooting

### App crashes on startup with null check error

This usually means one of the required environment variables is missing.

Checklist:
- Ensure a .env file exists in project root.
- Ensure these keys are present and non-empty:
  - SUPABASE_URL
  - SUPABASE_ANON_KEY
- Run flutter pub get again after creating or editing .env.

### Changes to providers/routes/models are not reflected

Generated files may be stale.

Fix:
- Run: dart run build_runner build -d
- For active development, run: dart run build_runner watch -d

### Build errors after dependency updates

Cached artifacts can become inconsistent.

Fix sequence:
- flutter clean
- flutter pub get
- dart run build_runner build -d

### Supabase auth works but data queries fail

Possible causes:
- Wrong project URL/key in .env
- Missing database objects or RPCs in your Supabase project
- Migration not applied

Fix:
- Verify credentials in .env
- Check that schema objects and RPC functions from
  supabase/migrations/20260416150811_remote_schema.sql
  exist in your Supabase database

### Route generation/type route issues

If typed routes stop compiling, regenerate code:
- dart run build_runner build -d

If errors persist, check imports and part files in core/routes.

## Known Limitations

- Leaderboard currently uses local mock data in provider code and is not yet backed by Supabase.
- Notification settings are local-device preferences only and do not trigger a server-side push pipeline.
- Theme preference is stored per device and does not currently sync across devices.
- Slide completion/progress updates depend on Supabase RPC availability and network connectivity; there is no offline sync queue.

## Profile Flow Notes

- Profile edit and avatar picker presentation screens now use HookConsumerWidget with flutter_hooks state/lifecycle handling.
- Edit Profile save persists both display name and selected avatar seed.
- Avatar picker still supports random seed shuffling and applies the picked avatar through profile update + provider invalidation.

## Notes

- Source of truth for app configuration is code and pubspec.
- If documentation and implementation diverge, implementation should be treated as authoritative.
