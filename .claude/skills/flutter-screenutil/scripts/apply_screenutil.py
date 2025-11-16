#!/usr/bin/env python3
"""
Flutter ScreenUtil Auto-Converter
Automatically applies ScreenUtil responsive units to Flutter code.

Rules:
1. If SAME LINE has both width AND height → both get .w
2. If a WIDGET BLOCK has both width and height (on different lines) → both get .w
3. If ONLY height exists in widget → height gets .h
4. fontSize → gets .sp
5. BorderRadius → gets .r
6. EdgeInsets values → get .w
"""

import re
import sys


def has_screenutil_import(content: str) -> bool:
    """Check if the file already has ScreenUtil import."""
    import_pattern = r"import\s+['\"]package:flutter_screenutil/flutter_screenutil\.dart['\"]"
    return bool(re.search(import_pattern, content))


def add_screenutil_import(content: str) -> str:
    """Add ScreenUtil import after the last import statement."""
    if has_screenutil_import(content):
        return content
    
    # Find the last import statement
    import_pattern = r"(import\s+['\"][^'\"]+['\"];)"
    imports = list(re.finditer(import_pattern, content))
    
    if imports:
        last_import = imports[-1]
        insert_pos = last_import.end()
        screenutil_import = "\nimport 'package:flutter_screenutil/flutter_screenutil.dart';"
        content = content[:insert_pos] + screenutil_import + content[insert_pos:]
    else:
        # No imports found, add at the beginning
        content = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n\n" + content
    
    return content


def find_widget_start(lines, from_line):
    """Find the line where the widget containing from_line starts."""
    # Look backwards for widget declaration
    for i in range(from_line, max(0, from_line - 20), -1):
        if re.search(r'\b(Container|SizedBox|Box|Card|AnimatedContainer)\s*\(', lines[i]):
            return i
    return from_line


def find_widget_end(lines, start_line):
    """Find the line where the widget ends."""
    paren_count = lines[start_line].count('(') - lines[start_line].count(')')
    
    # Increased range to 100 lines to handle larger widgets
    for i in range(start_line + 1, min(len(lines), start_line + 100)):
        paren_count += lines[i].count('(') - lines[i].count(')')
        if paren_count <= 0:
            return i
    
    return start_line


def get_widget_block(lines, line_idx):
    """Get the widget block that contains line_idx."""
    start_line = find_widget_start(lines, line_idx)
    end_line = find_widget_end(lines, start_line)
    return '\n'.join(lines[start_line:end_line + 1])


def widget_block_has_both_dimensions(widget_block):
    """Check if a widget block has both width and height properties."""
    has_width = bool(re.search(r'\bwidth:\s*\d+', widget_block))
    has_height = bool(re.search(r'\bheight:\s*\d+', widget_block))
    return has_width, has_height


def apply_width_height_units(content: str) -> str:
    """
    Apply .w and .h units to width and height properties.
    
    Process each line and determine context from the enclosing widget block.
    """
    lines = content.split('\n')
    result_lines = []
    
    for i, line in enumerate(lines):
        modified_line = line
        
        # Check if this line has width or height
        has_width_prop = bool(re.search(r'\bwidth:\s*\d+', line))
        has_height_prop = bool(re.search(r'\bheight:\s*\d+', line))
        
        if has_width_prop or has_height_prop:
            # Get the widget block context
            widget_block = get_widget_block(lines, i)
            block_has_width, block_has_height = widget_block_has_both_dimensions(widget_block)
            
            # Apply width unit (always .w)
            if has_width_prop:
                modified_line = re.sub(
                    r'\bwidth:\s*(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
                    r'width: \1.w',
                    modified_line
                )
            
            # Apply height unit
            if has_height_prop:
                # Use .w if widget has both dimensions, .h otherwise
                height_unit = 'w' if (block_has_width and block_has_height) else 'h'
                modified_line = re.sub(
                    r'\bheight:\s*(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
                    rf'height: \1.{height_unit}',
                    modified_line
                )
        
        result_lines.append(modified_line)
    
    return '\n'.join(result_lines)


def apply_edge_insets_units(content: str) -> str:
    """Apply .w units to EdgeInsets values."""
    
    # EdgeInsets.all(value)
    content = re.sub(
        r'EdgeInsets\.all\((\d+(?:\.\d+)?)\b(?!\.([whrsp]+))\)',
        r'EdgeInsets.all(\1.w)',
        content
    )
    
    # EdgeInsets.symmetric - horizontal and vertical
    def replace_symmetric(match):
        full_match = match.group(0)
        full_match = re.sub(
            r'(horizontal|vertical):\s*(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
            r'\1: \2.w',
            full_match
        )
        return full_match
    
    content = re.sub(r'EdgeInsets\.symmetric\([^)]+\)', replace_symmetric, content)
    
    # EdgeInsets.only - left, top, right, bottom
    def replace_only(match):
        full_match = match.group(0)
        for direction in ['left', 'top', 'right', 'bottom']:
            full_match = re.sub(
                rf'{direction}:\s*(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
                rf'{direction}: \1.w',
                full_match
            )
        return full_match
    
    content = re.sub(r'EdgeInsets\.only\([^)]+\)', replace_only, content)
    
    # EdgeInsets.fromLTRB(left, top, right, bottom)
    def replace_ltrb(match):
        text = match.group(0)
        text = re.sub(
            r'(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
            r'\1.w',
            text
        )
        return text
    
    content = re.sub(r'EdgeInsets\.fromLTRB\([^)]+\)', replace_ltrb, content)
    
    return content


def apply_font_size_units(content: str) -> str:
    """Apply .sp units to fontSize properties."""
    return re.sub(
        r'\bfontSize:\s*(\d+(?:\.\d+)?)\b(?!\.(?:sp|w|h|r))',
        r'fontSize: \1.sp',
        content
    )


def apply_border_radius_units(content: str) -> str:
    """Apply .r units to BorderRadius values."""
    
    # BorderRadius.circular(number)
    content = re.sub(
        r'BorderRadius\.circular\((\d+(?:\.\d+)?)\b(?!\.([whrsp]+))\)',
        r'BorderRadius.circular(\1.r)',
        content
    )
    
    # Radius.circular(number)
    content = re.sub(
        r'Radius\.circular\((\d+(?:\.\d+)?)\b(?!\.([whrsp]+))\)',
        r'Radius.circular(\1.r)',
        content
    )
    
    # Radius.elliptical(x, y)
    def replace_elliptical(match):
        text = match.group(0)
        text = re.sub(
            r'(\d+(?:\.\d+)?)\b(?!\.([whrsp]+))',
            r'\1.r',
            text
        )
        return text
    
    content = re.sub(r'Radius\.elliptical\([^)]+\)', replace_elliptical, content)
    
    return content


def remove_duplicate_units(content: str) -> str:
    """Remove duplicate unit applications like .w.w or .sp.sp."""
    patterns = [
        (r'\.w\.w+', '.w'),
        (r'\.h\.h+', '.h'),
        (r'\.sp\.sp+', '.sp'),
        (r'\.r\.r+', '.r'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    return content


def convert_flutter_code(content: str) -> str:
    """Main conversion function that applies all ScreenUtil transformations."""
    
    # Add import if not present
    content = add_screenutil_import(content)
    
    # Apply transformations
    content = apply_width_height_units(content)
    content = apply_edge_insets_units(content)
    content = apply_font_size_units(content)
    content = apply_border_radius_units(content)
    
    # Clean up any duplicate units
    content = remove_duplicate_units(content)
    
    return content


def main():
    if len(sys.argv) != 3:
        print("Usage: python apply_screenutil.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        converted_content = convert_flutter_code(content)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(converted_content)
        
        print(f"✅ Successfully converted {input_file} to {output_file}")
        
    except FileNotFoundError:
        print(f"❌ Error: File {input_file} not found")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
