import json
import re
from typing import Any, Dict, List, Set


class EnumParser:
    def __init__(self, content: str):
        self.content = content
        self.parsed_enums: Dict[str, List[Dict[str, Any]]] = {}
        self.enum_dependencies: Set[str] = set()

    def find_enum_definition(self, enum_name: str) -> str:
        """
        Find the full definition of an enum in the content.
        """
        enum_pattern = rf"pub enum {enum_name} \{{([\s\S]*?)\}}"
        enum_match = re.search(enum_pattern, self.content)

        return enum_match.group(1) if enum_match else ""

    def clean_enum_content(self, content: str) -> str:
        """
        Remove comments from enum content.
        """
        # Remove multi-line comments
        content = re.sub(r"/\*[\s\S]*?\*/", "", content)
        # Remove single-line comments
        content = re.sub(r"//[^\n]*\n", "\n", content)

        return content

    def parse_enum_variants(self, enum_name: str) -> List[Dict[str, Any]]:
        """
        Parse an enum's variants and detect dependencies.
        """
        if enum_name in self.parsed_enums:
            return self.parsed_enums[enum_name]

        enum_content = self.find_enum_definition(enum_name)
        if not enum_content:
            return []

        enum_content = self.clean_enum_content(enum_content)
        variants = []

        variant_pattern = r"([A-Za-z]+)(?:\((.*?)\))?,"
        matches = re.finditer(variant_pattern, enum_content)

        for match in matches:
            variant_name = match.group(1)
            variant_type = match.group(2)

            variant_info = {"name": variant_name}

            if variant_type:
                variant_info["type"] = variant_type.strip()

                # Check if the variant type is another enum
                enum_types = re.findall(r"([A-Z][a-zA-Z]+)", variant_type)
                for enum_type in enum_types:
                    if self.find_enum_definition(enum_type):
                        self.enum_dependencies.add(enum_type)

            variants.append(variant_info)

        self.parsed_enums[enum_name] = variants
        return variants

    def parse_all_actions(self) -> Dict[str, Any]:
        """
        Parse all actions in the Action enum and all dependent enums recursively.
        """
        self.parse_enum_variants("Action")

        processed_deps = set()
        while self.enum_dependencies - processed_deps:
            new_dep = (self.enum_dependencies - processed_deps).pop()
            self.parse_enum_variants(new_dep)
            processed_deps.add(new_dep)

        result = {
            "Actions": self.parsed_enums["Action"],
            "Dependencies": {
                enum_name: self.parsed_enums[enum_name]
                for enum_name in self.enum_dependencies
            },
        }

        return result


def main():
    with open("action.rs", "r") as file:
        content = file.read()

    parser = EnumParser(content)
    result = parser.parse_all_actions()

    with open("shortcut-actions.json", "w") as f:
        json.dump(result, f, indent=2)


if __name__ == "__main__":
    main()
