import re
import sys
import os

# Détection du type de bump
bump = os.environ.get('TYPE_BUMP', 'patch')

with open('pubspec.yaml', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.startswith('version:'):
        match = re.match(r'version: (\d+)\.(\d+)\.(\d+)\+(\d+)', line)
        if not match:
            sys.exit(1)
        major, minor, patch, build = map(int, match.groups())
        if bump == 'major':
            major += 1
            minor = 0
            patch = 0
        elif bump == 'minor':
            minor += 1
            patch = 0
        elif bump == 'patch':
            patch += 1
        else:
            sys.exit(1)
        build += 1
        lines[i] = f'version: {major}.{minor}.{patch}+{build}\n'
        break
else:
    sys.exit(1)

with open('pubspec.yaml', 'w') as f:
    f.writelines(lines)

with open('new_version.txt', 'w') as tmp:
    tmp.write(f'{major}.{minor}.{patch}') 