import json
import re
import sys
from typing import Any, Dict, List, Set


class EnumParser:
    def __init__(self, content: str):
        self.content = content
        self.parsed_enums: Dict[str, List[Dict[str, Any]]] = {}
        self.enum_dependencies: Set[str] = set()
        self.processing_enums: Set[str] = set()

    def find_enum_definition(self, enum_name: str) -> str:
        enum_pattern = rf"enum {enum_name} \{{([\s\S]*?)\}}"
        enum_match = re.search(enum_pattern, self.content)

        return enum_match.group(1) if enum_match else ""

    def clean_enum_content(self, content: str) -> str:
        content = re.sub(r"/\*[\s\S]*?\*/", "", content)
        content = re.sub(r"//[^\n]*\n", "\n", content)

        return content

    def extract_enum_types(self, variant_type: str) -> Set[str]:
        enum_types = set(re.findall(r"([A-Z][a-zA-Z]+)", variant_type))
        return {
            enum_type
            for enum_type in enum_types
            if self.find_enum_definition(enum_type)
        }

    def parse_enum_variants(self, enum_name: str) -> List[Dict[str, Any]]:
        if enum_name in self.parsed_enums:
            return self.parsed_enums[enum_name]
        if enum_name in self.processing_enums:
            return []

        enum_content = self.find_enum_definition(enum_name)
        if not enum_content:
            return []

        self.processing_enums.add(enum_name)
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

                nested_enums = self.extract_enum_types(variant_type)
                for nested_enum in nested_enums:
                    self.enum_dependencies.add(nested_enum)
                    self.parse_enum_variants(nested_enum)

            variants.append(variant_info)

        self.processing_enums.remove(enum_name)
        self.parsed_enums[enum_name] = variants
        return variants

    def parse_all_actions(self) -> Dict[str, Any]:
        self.parse_enum_variants("Action")

        processed_deps = set()
        to_process = self.enum_dependencies.copy()

        while to_process:
            current_dep = to_process.pop()
            if current_dep not in processed_deps:
                self.parse_enum_variants(current_dep)
                processed_deps.add(current_dep)
                to_process.update(self.enum_dependencies - processed_deps)

        result = {
            "Actions": self.parsed_enums["Action"],
            "Dependencies": {
                enum_name: self.parsed_enums[enum_name]
                for enum_name in self.enum_dependencies
            },
        }

        return result


def main():
    input = sys.argv[1]
    output = sys.argv[2]

    with open(input, "r") as file:
        content = file.read()

    parser = EnumParser(content)
    result = parser.parse_all_actions()

    with open(output, "w") as file:
        json.dump(result, file, indent=4)


if __name__ == "__main__":
    main()
