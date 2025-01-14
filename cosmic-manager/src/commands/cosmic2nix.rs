use crate::{
    commands::Command,
    config::{get_cosmic_configurations, parse_configuration_path, read_configuration},
    utils::to_nix_expression,
};
use clap::Args;
use std::{collections::HashMap, io::Error};
use walkdir::WalkDir;

#[derive(Args)]
pub struct Cosmic2NixCommand {
    /// The XDG directories to search for COSMIC configurations.
    #[arg(short, long, value_delimiter = ',', default_value = "config,state")]
    xdg_dirs: Vec<String>,
}

struct ComponentData {
    version: u64,
    entries: HashMap<String, String>,
}

impl Command for Cosmic2NixCommand {
    type Err = Error;

    fn execute(&self) -> Result<(), Self::Err> {
        println!("{{ cosmicLib, ... }}: ");
        println!("{{");
        println!("  wayland.desktopManager.cosmic = {{");
        println!("    enable = true;");
        for xdg_dir in &self.xdg_dirs {
            let cosmic_path = get_cosmic_configurations(xdg_dir)?;
            let mut components: HashMap<String, ComponentData> = HashMap::new();

            println!("    {}File = {{", xdg_dir);
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
                println!("      \"{}\" = {{", component_name);
                println!("        version = {};", component_data.version);
                println!("        entries = {{");
                for (entry_name, content) in component_data.entries {
                    to_nix_expression(&entry_name, &content, "          ");
                }
                println!("        }};");
                println!("      }};");
            }

            println!("    }};");
        }
        println!("  }};");
        println!("}}");

        Ok(())
    }
}
