import os

def fix_modals(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                
                if "showModalBottomSheet(" in content and "useRootNavigator: true" not in content:
                    new_content = content.replace("showModalBottomSheet(\n      context: context,", "showModalBottomSheet(\n      context: context,\n      useRootNavigator: true,")
                    new_content = new_content.replace("showModalBottomSheet(\n    context: context,", "showModalBottomSheet(\n    context: context,\n    useRootNavigator: true,")
                    
                    if new_content != content:
                        with open(filepath, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        print(f"Fixed {filepath}")

fix_modals("lib")
