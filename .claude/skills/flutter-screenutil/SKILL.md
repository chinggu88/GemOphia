---
name: flutter-screenutil
description: Automatically convert Flutter widget properties to use ScreenUtil responsive units for responsive design. Use when the user requests to make Flutter code responsive, apply ScreenUtil, or convert to responsive design with phrases like "반응형 코드로 변경해줘", "make this responsive", "apply ScreenUtil", or when working with Flutter UI code that needs responsive sizing. Converts width/height properties to .w/.h, fontSize to .sp, and BorderRadius to .r units.
---

# Flutter ScreenUtil Auto-Converter

Automatically apply ScreenUtil responsive units to Flutter code for consistent cross-device UI scaling.

## Overview

This skill converts Flutter widget properties to use flutter_screenutil package units:
- Width properties → `.w`
- Height properties → `.h` (only when no width property exists)
- Font sizes → `.sp`
- Border radius → `.r`

It also automatically adds the ScreenUtil import if not present.

## Conversion Rules

### Width Properties
Apply `.w` to all width values:
```dart
Container(width: 200)      → Container(width: 200.w)
SizedBox(width: 100)       → SizedBox(width: 100.w)
```

### Height Properties
Apply `.h` when height exists alone, but apply `.w` when BOTH width and height exist:
```dart
SizedBox(height: 50)                    → SizedBox(height: 50.h)
Container(width: 200, height: 100)      → Container(width: 200.w, height: 100.w)
```

### Font Size
Apply `.sp` to fontSize only (not letterSpacing, line height, etc.):
```dart
TextStyle(fontSize: 16)    → TextStyle(fontSize: 16.sp)
```

### Border Radius
Apply `.r` to all BorderRadius values:
```dart
BorderRadius.circular(10)              → BorderRadius.circular(10.r)
Radius.circular(8)                     → Radius.circular(8.r)
BorderRadius.only(topLeft: Radius.circular(12))  
  → BorderRadius.only(topLeft: Radius.circular(12.r))
```

### Import Statement
Automatically add if not present:
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
```

## Usage Instructions

### For User-Uploaded Files

When user uploads a Flutter file and requests responsive conversion:

1. Read the uploaded file from `/mnt/user-data/uploads/`
2. Copy it to working directory
3. Run the conversion script:
```bash
python3 scripts/apply_screenutil.py input.dart output.dart
```
4. Move the converted file to `/mnt/user-data/outputs/` for user download

### For Code in Conversation

When user provides Flutter code directly in the conversation:

1. Create a temporary file with the code
2. Run the conversion script
3. Display the converted code to the user

### Workflow Example

```bash
# Copy uploaded file to working directory
cp /mnt/user-data/uploads/my_widget.dart ./my_widget.dart

# Apply ScreenUtil conversion
python3 /mnt/skills/user/flutter-screenutil/scripts/apply_screenutil.py my_widget.dart my_widget_responsive.dart

# Move to outputs for user download
cp my_widget_responsive.dart /mnt/user-data/outputs/
```

## Properties Converted

- **width** → `.w`
- **height** → `.h` (only height) or `.w` (with width)
- **fontSize** → `.sp`
- **BorderRadius** → `.r`
- **EdgeInsets** (padding, margin) → `.w`

## Properties NOT Converted

- `letterSpacing`, `height` (line height), `wordSpacing` in TextStyle
- Any property not explicitly listed above

## Edge Cases

- **Already converted**: Skip values with existing units (`.w`, `.h`, `.sp`, `.r`)
- **Zero values**: Convert zeros too (`width: 0` → `width: 0.w`)
- **Decimals**: Support decimal values (`fontSize: 16.5` → `fontSize: 16.5.sp`)

## Additional Resources

For detailed conversion rules and examples, see `references/conversion_rules.md`.
