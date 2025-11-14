# Flutter ScreenUtil Conversion Rules

## Overview

This document defines the exact rules for converting Flutter code to use ScreenUtil responsive units.

## Conversion Rules

### 1. Width Property
- **Rule**: Always apply `.w` to width values
- **Pattern**: `width: <number>` → `width: <number>.w`
- **Examples**:
  ```dart
  // Before
  Container(width: 200)
  SizedBox(width: 100)
  
  // After
  Container(width: 200.w)
  SizedBox(width: 100.w)
  ```

### 2. Height Property
- **Rule**: Apply `.w` if both width and height exist, otherwise apply `.h`
- **Pattern**: 
  - Both width & height: `height: <number>` → `height: <number>.w`
  - Only height: `height: <number>` → `height: <number>.h`
- **Examples**:
  ```dart
  // Before (only height)
  Container(height: 100)
  SizedBox(height: 50)
  
  // After (only height)
  Container(height: 100.h)
  SizedBox(height: 50.h)
  
  // Before (with width)
  Container(width: 200, height: 100)
  
  // After (with width - both use .w)
  Container(width: 200.w, height: 100.w)
  ```

### 3. Font Size
- **Rule**: Apply `.sp` to fontSize values ONLY
- **Pattern**: `fontSize: <number>` → `fontSize: <number>.sp`
- **Scope**: ONLY fontSize, NOT letterSpacing, height, or other text properties
- **Examples**:
  ```dart
  // Before
  TextStyle(fontSize: 16)
  Text('Hello', style: TextStyle(fontSize: 24))
  
  // After
  TextStyle(fontSize: 16.sp)
  Text('Hello', style: TextStyle(fontSize: 24.sp))
  
  // NOT converted (other properties)
  TextStyle(
    fontSize: 16.sp,      // Converted
    letterSpacing: 1.5,   // NOT converted
    height: 1.2,          // NOT converted
  )
  ```

### 4. BorderRadius
- **Rule**: Automatically add ScreenUtil import if not present
- **Pattern**: Add after the last import statement
- **Import**: `import 'package:flutter_screenutil/flutter_screenutil.dart';`

## Properties NOT Converted

The following properties should NOT be converted:

- `padding` (EdgeInsets values)
- `margin` (EdgeInsets values)
- `letterSpacing` in TextStyle
- `height` (line height) in TextStyle
- `wordSpacing` in TextStyle
- Any property not explicitly listed in the conversion rules above

## Edge Cases

### Already Converted Values
- Skip values that already have units (`.w`, `.h`, `.sp`, `.r`)
- Example: `width: 100.w` should not become `width: 100.w.w`

### Zero Values
- Zero values should also be converted
- Example: `width: 0` → `width: 0.w`

### Decimal Values
- Decimal values are supported
- Example: `fontSize: 16.5` → `fontSize: 16.5.sp`

## Complete Example

```dart
// BEFORE
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Title',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            'Subtitle',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// AFTER
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      height: 100.h,
      padding: EdgeInsets.all(16),  // NOT converted
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            'Title',
            style: TextStyle(fontSize: 24.sp),
          ),
          SizedBox(height: 10.h),  // Only height, so .h applied
          Text(
            'Subtitle',
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
```
