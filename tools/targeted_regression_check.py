import os
import re

def check_missing_factories():
    """Entitylarda majburiy factorylar borligini tekshiradi."""
    errors = []
    entities_dir = "lib/features"
    for root, _, files in os.walk(entities_dir):
        for file in files:
            if file.endswith("_entities.dart") or file.endswith("_model.dart"):
                path = os.path.join(root, file)
                content = open(path).read()
                if "class" in content and "fromJson" not in content and "factory" not in content:
                    if "Equatable" in content: # Faqat asosiy entitylarni tekshiramiz
                        errors.append(f"Missing fromJson factory in: {path}")
    return errors

if __name__ == "__main__":
    issues = check_missing_factories()
    if issues:
        print(f"Targeted Regressions: {len(issues)} issue(s)")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("Targeted Regressions: 0 issue(s)")
