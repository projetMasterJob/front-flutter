import re
import sys
import os

type_bump = os.environ.get('TYPE_BUMP', 'patch')
with open('pubspec.yaml', 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if line.startswith('version:'):
        version_line = line
        break
else:
    print('Aucune version trouvée dans pubspec.yaml')
    sys.exit(1)
match = re.match(r'version: (\d+)\.(\d+)\.(\d+)\+(\d+)', version_line)
if not match:
    print('Format de version non reconnu')
    sys.exit(1)
major, minor, patch, build = map(int, match.groups())
if type_bump == 'major':
    major += 1
    minor = 0
    patch = 0
elif type_bump == 'minor':
    minor += 1
    patch = 0
elif type_bump == 'patch':
    patch += 1
else:
    print('Type de bump inconnu')
    sys.exit(1)
build += 1
new_version = f'version: {major}.{minor}.{patch}+{build}\n'
lines[i] = new_version
with open('pubspec.yaml', 'w') as f:
    f.writelines(lines)
print(f'Nouvelle version: {major}.{minor}.{patch}+{build}')
tmp = open('new_version.txt', 'w')
tmp.write(f'{major}.{minor}.{patch}')
tmp.close() 