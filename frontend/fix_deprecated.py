import os
import re

def fix_deprecated_methods(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Replace withOpacity(0.1) with withValues(alpha: 0.1)
                    # This handles all opacity values
                    modified_content = re.sub(
                        r'withValues\(([\d.]+)\)',
                        r'withValues(alpha: \1)',
                        content
                    )
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                    
                    print(f"Fixed: {file_path}")
                except Exception as e:
                    print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    fix_deprecated_methods('lib')
