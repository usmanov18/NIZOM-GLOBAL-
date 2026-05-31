import os
import sys

def create_feature(feature_name):
    cap_name = feature_name.capitalize()
    base_path = f"lib/features/{feature_name}"
    
    # Structure
    folders = [
        "data/datasources", "data/repositories",
        "domain/entities", "domain/repositories", "domain/usecases",
        "presentation/bloc", "presentation/screens"
    ]
    for folder in folders:
        os.makedirs(os.path.join(base_path, folder), exist_ok=True)
    
    # Generate Bloc Skeleton
    with open(f"{base_path}/presentation/bloc/{feature_name}_bloc.dart", "w") as f:
        f.write(f"import 'package:flutter_bloc/flutter_bloc.dart';\n\nclass {cap_name}Bloc extends Bloc {{ {cap_name}Bloc() : super(null); }}\n")

    # Generate UI Skeleton
    with open(f"{base_path}/presentation/screens/{feature_name}_screen.dart", "w") as f:
        f.write(f"import 'package:flutter/material.dart';\n\nclass {cap_name}Screen extends StatelessWidget {{ const {cap_name}Screen({{super.key}}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('{cap_name}'))); }}\n")

    print(f"🚀 Feature '{feature_name}' Scaffolded with full Clean Arch patterns!")

if __name__ == "__main__":
    if len(sys.argv) > 1: create_feature(sys.argv[1])
