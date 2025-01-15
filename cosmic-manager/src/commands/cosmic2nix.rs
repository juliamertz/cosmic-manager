use crate::{
    commands::Command,
    config::{get_cosmic_configurations, parse_configuration_path, read_configuration},
    utils::to_nix_expression,
};
use clap::Args;
use std::{collections::HashMap, fs, io::Error, path::PathBuf};
use walkdir::WalkDir;

#[derive(Args)]
pub struct Cosmic2NixCommand {
    /// The XDG directories to search for COSMIC configurations.
    #[arg(short, long, value_delimiter = ',', default_value = "config,state")]
    xdg_dirs: Vec<String>,

    output_file: Option<PathBuf>,
}

struct ComponentData {
    version: u64,
    entries: HashMap<String, String>,
}

impl Command for Cosmic2NixCommand {
    type Err = Error;

    fn execute(&self) -> Result<(), Self::Err> {
        let mut output = String::new();

        output.push_str("{ cosmicLib, ... }:\n");
        output.push_str("{\n");
        output.push_str("  wayland.desktopManager.cosmic = {\n");
        output.push_str("    enable = true;\n");

        for xdg_dir in &self.xdg_dirs {
            let cosmic_path = get_cosmic_configurations(xdg_dir)?;
            let mut components: HashMap<String, ComponentData> = HashMap::new();

            output.push_str(&format!("    {}File = {{\n", xdg_dir));

            for entry in WalkDir::new(&cosmic_path)
                .into_iter()
                .filter_map(|e| e.ok())
                .filter(|e| e.file_type().is_file())
            {
                if let Some((component, version, entry_name)) =
                    parse_configuration_path(entry.path())
                {
                    match read_configuration(&component, &version, &entry_name, xdg_dir) {
                        Ok(content) => {
                            components
                                .entry(component.clone())
                                .or_insert_with(|| ComponentData {
                                    version,
                                    entries: HashMap::new(),
                                })
                                .entries
                                .insert(entry_name, content);
                        }
                        Err(e) => {
                            eprintln!("Failed to read configuration: {}", e);
                        }
                    }
                }
            }

            for (component_name, component_data) in components {
                output.push_str(&format!("      \"{}\" = {{\n", component_name));
                output.push_str(&format!("        version = {};\n", component_data.version));
                output.push_str("        entries = {\n");

                let mut formatted_entries = String::new();
                for (entry_name, content) in component_data.entries {
                    formatted_entries.push_str(&to_nix_expression(
                        Some(&entry_name),
                        &content,
                        "          ",
                    ));
                }
                output.push_str(&formatted_entries);

                output.push_str("        };\n");
                output.push_str("      };\n");
            }

            output.push_str("    };\n");
        }
        output.push_str("  };\n");
        output.push_str("}\n");

        match &self.output_file {
            Some(path) => {
                fs::write(path, output)?;
                println!("Wrote COSMIC configuration to {}", path.display());
            }
            None => {
                println!("{}", output);
            }
        }

        Ok(())
    }
}
