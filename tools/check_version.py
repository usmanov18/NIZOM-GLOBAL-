import yaml
import sys

def check_version():
    with open('pubspec.yaml', 'r') as f:
        data = yaml.safe_load(f)
        version = data.get('version', '0.0.0')
        if '+' not in version:
            print(f"❌ Invalid Versioning: {version}. Use semantic versioning (e.g., 1.2.0+1)")
            return False
        print(f"✅ Version check passed: {version}")
        return True

if __name__ == "__main__":
    sys.exit(0 if check_version() else 1)
