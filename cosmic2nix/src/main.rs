use std::{collections::HashMap, env, fs, path::Path};
use walkdir::WalkDir;

struct NixConfig {
    version: u64,
    entries: HashMap<String, String>,
}

fn main() {
    let config_home = env::var("XDG_CONFIG_HOME").unwrap_or_else(|_| {
        let home = env::var("HOME").unwrap();
        format!("{}/.config", home)
    });
    let cosmic_path = Path::new(&config_home).join("cosmic");
    let indent = 2;

    let mut configs: HashMap<String, NixConfig> = HashMap::new();

    if !cosmic_path.exists() {
        println!("No configurations found.");
        return;
    }

    for entry in WalkDir::new(&cosmic_path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().is_file())
    {
        if let Some((component, version, entry_name)) = parse_configuration_path(entry.path()) {
            if let Ok(content) = fs::read_to_string(entry.path()) {
                let value = escape_string(content.trim());

                configs
                    .entry(component.clone())
                    .or_insert_with(|| NixConfig {
                        version,
                        entries: HashMap::new(),
                    })
                    .entries
                    .insert(entry_name, value);
            }
        }
    }

    println!("{{");
    println!(
        "{:indent$}wayland.desktopManager.cosmic = {{",
        "",
        indent = indent
    );
    println!("{:indent$}enable = true;", "", indent = indent * 2);
    println!("{:indent$}file = {{", "", indent = indent * 2);
    for (component, config) in configs {
        println!(
            "{:indent$}\"{}\" = {{",
            "",
            escape_string(&component),
            indent = indent * 3
        );
        println!(
            "{:indent$}version = {};",
            "",
            config.version,
            indent = indent * 4
        );
        println!("{:indent$}entries = {{", "", indent = indent * 4);
        for (key, value) in config.entries {
            println!(
                "{:indent$}{} = \"{}\";",
                "",
                escape_string(&key),
                value,
                indent = indent * 5
            )
        }
        println!("{:indent$}}};", "", indent = indent * 4);
        println!("{:indent$}}};", "", indent = indent * 3);
    }
    println!("{:indent$}}};", "", indent = indent * 2);
    println!("{:indent$}}};", "", indent = indent);
    println!("}}");
}

fn parse_configuration_path(path: &Path) -> Option<(String, u64, String)> {
    let parts: Vec<_> = path.iter().collect();
    if parts.len() < 4 {
        return None;
    }

    let entry_name = parts.last()?.to_str()?.to_string();
    let version_str = parts.get(parts.len() - 2)?.to_str()?;
    let version = version_str.strip_prefix('v')?.parse().ok()?;
    let component = parts.get(parts.len() - 3)?.to_str()?.to_string();

    Some((component, version, entry_name))
}

fn escape_string(string: &str) -> String {
    string
        .chars()
        .map(|char| match char {
            '"' => "\\\"".to_string(),
            '\\' => "\\\\".to_string(),
            '\n' => "\\n".to_string(),
            '\r' => "\\r".to_string(),
            '\t' => "\\t".to_string(),
            _ => char.to_string(),
        })
        .collect()
}
