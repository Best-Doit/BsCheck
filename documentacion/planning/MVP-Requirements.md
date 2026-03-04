# BsCheck MVP Requirements

**Product**: BsCheck  
**Version**: 1.0 (MVP)  
**Platform**: Android (offline)  
**Framework**: Flutter

---

## 1. MVP Goal

Deliver a mobile application that allows users to quickly verify if a **Bolivian banknote** is **valid** or **disabled**, working **100% offline** and optimized for day‑to‑day field use.

**Primary user goal (happy path):**
- User opens the app.
- Scans or types the banknote serial.
- In **< 1 second** sees a clear result:
  - **VALID**
  - **DISABLED**
  - **NOT RECOGNIZED**

---

## 2. MVP Scope (What is IN)

### 2.1 Supported banknotes

- **Denominations**:
  - 10 BOB
  - 20 BOB
  - 50 BOB
- **Series**:
  - Only **series "B"** in MVP.

### 2.2 Input methods

- **Camera + OCR**:
  - Use device camera to capture the serial printed on the banknote.
  - Run OCR locally on the device (no server).
- **Manual input**:
  - Numeric text field to manually type the serial number.

### 2.3 Validation capabilities

- Validate a serial number **offline** against a local rules file containing **disabled ranges**.
- Use a **binary search**–based algorithm over ordered ranges for fast lookup.
- Return one of these results:
  - **VALID** → Serial not found in any disabled range.
  - **DISABLED** → Serial belongs to at least one disabled range.
  - **NOT RECOGNIZED** → OCR/manual input invalid or cannot be parsed.

### 2.4 Local history

- Store a **local history** of past checks, including:
  - Date/time of check
  - Serial number
  - Result (VALID / DISABLED / NOT RECOGNIZED)
- History stored **locally** only (no sync in MVP).

### 2.5 Offline behavior

- App must be fully functional **without any network connection**:
  - OCR runs locally.
  - Rules file is bundled in the app assets.
  - History is stored locally.

---

## 3. Out of Scope (for MVP)

The following items are **explicitly excluded** from MVP to avoid ambiguity:

- Automatic recognition of banknote **denomination** from the image.
- Detection of **counterfeit/fake** banknotes (only checks disabled ranges).
- Online or automatic **rules update** (rules are static in assets).
- Support for **other currencies** or other countries.
- User accounts, authentication, or cloud sync.
- Web, iOS, or desktop releases (Android first; others in future roadmap).

---

## 4. User Personas & Usage Scenarios

### 4.1 Target users

- Merchants and shop owners.
- Cashiers.
- Street vendors / market sellers.
- Informal financial operators.

### 4.2 Typical scenario (Camera)

1. Merchant receives a banknote.
2. Opens BsCheck.
3. Taps **"Scan banknote"**.
4. Points camera at the banknote serial.
5. App highlights the detected serial and runs validation.
6. Within **< 1 second** sees one of:
   - "⚠ Disabled banknote" (visual warning, high contrast colors).
   - "✔ Valid banknote".

### 4.3 Typical scenario (Manual input)

1. User opens BsCheck.
2. Taps **"Enter serial"**.
3. Types `87280145`.
4. Taps **"Validate"**.
5. App shows: **"Disabled"** result and stores it in history.

---

## 5. Functional Requirements

### 5.1 OCR & Camera (FR1)

- The app **must** be able to read numeric serials using the camera and OCR.
- Use **on-device OCR** (ML Kit Text Recognition) via Flutter plugin.
- OCR pipeline:
  - Capture frame from camera preview.
  - Run OCR on the frame.
  - Extract text blocks and filter candidates by regex `[0-9]{7,9}`.
  - Choose the most likely candidate (e.g., longest numeric match, central area).

### 5.2 Validation against local rules (FR2)

- The app **must** validate the serial against a **local JSON rules file**.
- Rules file is packaged in `assets/rules/rules_v1.json` and loaded at startup or on first use.
- Format:

  ```json
  {
    "version": 1,
    "currency": "BOB",
    "rules": [
      {
        "denomination": 10,
        "series": "B",
        "start": 77100001,
        "end": 77550000
      },
      {
        "denomination": 20,
        "series": "B",
        "start": 87280145,
        "end": 91646549
      }
    ]
  }
  ```

- Each rule is represented by a `RuleRange` model:

  ```dart
  class RuleRange {
    final int denomination;
    final String series;
    final int start;
    final int end;
  }
  ```

### 5.3 Validation performance (FR3)

- The **validation step itself** (lookup in memory) **must** be under **100 ms**.
- Expected: a few milliseconds on modern devices using binary search on ordered ranges.

### 5.4 Manual serial input (FR4)

- Provide a numeric input screen where the user can type a serial.
- Input constraints:
  - Accept only digits 0–9.
  - Length between **7 and 9 digits** (matching regex `[0-9]{7,9}`).
- Validate when the user taps **"Validate"** or presses the keyboard action.

### 5.5 History of queries (FR5)

- Every validation (OCR or manual) should append an entry to a **local history**:
  - `timestamp` (local device time)
  - `serial` (numeric string)
  - `result` (VALID / DISABLED / NOT_RECOGNIZED)
- History is persisted using a local key–value store (Hive) and shown in a dedicated **History screen**.

---

## 6. Non‑Functional Requirements

### 6.1 Offline first (NFR1)

- The app must **not require network** for:
  - Launching.
  - Scanning.
  - Validating a banknote.
  - Viewing history.

### 6.2 Speed (NFR2)

- Overall validation (from having the serial text to result) should be:
  - **Target**: < 200 ms total.
  - Includes: parsing + lookup + UI update.
- Per PRD specific metrics:
  - **Rules loading**: < 20 ms.
  - **Validation core**: < 5 ms.

### 6.3 App size (NFR3)

- Android APK/AAB size should be **< 60 MB** for the MVP.
- Decisions to support this:
  - Use only the necessary ML Kit models.
  - Avoid unnecessary plugins and large assets.

---

## 7. Technical Architecture (High‑Level)

### 7.1 Layers (Clean Architecture – simplified)

- **presentation**: UI (screens, widgets, state management).
- **application**: use cases / controllers (e.g. `ValidateSerialUseCase`).
- **domain**: entities and repository interfaces.
- **data**: data sources and repository implementations (rules + history).

### 7.2 Project structure (target)

```text
lib/
  core/
    constants/
    utils/

  features/
    validation/
      presentation/
        scan_page.dart
        result_page.dart
      application/
        validate_serial_usecase.dart
      domain/
        entities/
          banknote_serial.dart
          validation_result.dart
        repositories/
          rules_repository.dart
      data/
        datasources/
          rules_local_datasource.dart
        repositories/
          rules_repository_impl.dart

    history/
      presentation/
        history_page.dart
      data/
        history_local_datasource.dart
```

---

## 8. Technology Stack (MVP)

- **Flutter**: 3.24.x (stable) or later compatible with PRD.
- **Dart**: 3.5+.
- **Minimum Android**: 8.0 (API 26).

### 8.1 Recommended libraries

- **State management**: `flutter_riverpod` ^2.5.1
- **OCR**:
  - `google_mlkit_text_recognition` ^0.11.0
  - `camera` ^0.11.0
- **Local storage**:
  - `hive` ^2.2.3
  - `hive_flutter` ^1.1.0
- **Utilities**:
  - `equatable` ^2.0.5
  - `intl` ^0.19.0
- **Code generation**:
  - `build_runner` ^2.4.9
  - `hive_generator` ^2.0.1

---

## 9. UI Requirements (MVP Screens)

### 9.1 Home screen

- Shows three main actions:
  - **Scan banknote** (primary button).
  - **Enter serial** (secondary button).
  - **History** (secondary button or icon).
- Simple, high‑contrast layout, optimized for one‑hand use.

### 9.2 Scan screen

- Full‑screen camera preview.
- Overlay (frame/guide) aligned to where the serial usually appears.
- Status area:
  - "Align the serial inside the frame" message.
  - Feedback when a serial is detected.
- On detection, automatically navigate or show the validation result clearly.

### 9.3 Result screen

- Shows:
  - **Result state**:
    - ✔ **Valid banknote** (green theme).
    - ⚠ **Disabled banknote** (warning/orange or red theme).
    - ❓ **Not recognized** (neutral/gray theme).
  - Serial number.
  - Denomination and series (if provided/selected by user).
- Actions:
  - **Back to home**.
  - Optional: **Check another** (shortcut).

### 9.4 History screen

- List of past checks with:
  - Date/time.
  - Serial.
  - Result icon/color.
- Most recent entries at the top.
- Optional action: clear history (can be added later if needed).

---

## 10. Security & Privacy

- No personal data collected or stored.
- Only store **serials and result metadata** in local history.
- No external network calls in MVP.

---

## 11. Deliverables for MVP

- Flutter project configured for Android.
- Clean Architecture–based structure as described.
- Functional OCR pipeline with camera and on‑device recognition.
- Validation engine using local rules file and binary search.
- Basic but clear UI for:
  - Home
  - Scan
  - Result
  - History
- Bundled `rules_v1.json` file under `assets/rules/`.

---

## 12. Time Estimate (for a configured agent)

- Estimated implementation time: **6–8 hours** (excluding future roadmap features).

