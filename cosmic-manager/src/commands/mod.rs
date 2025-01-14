mod cosmic2nix;

use crate::commands::cosmic2nix::Cosmic2NixCommand;
use clap::Subcommand;
use std::io::Error;

#[derive(Subcommand)]
pub enum Commands {
    /// Convert your COSMIC configurations to cosmic-manager configuration.
    #[clap(name = "cosmic2nix")]
    Cosmic2Nix(Cosmic2NixCommand),
}

impl Commands {
    pub(crate) fn execute(&self) -> Result<(), Error> {
        match self {
            Commands::Cosmic2Nix(cmd) => cmd.execute(),
        }
    }
}

pub trait Command {
    type Err;

    fn execute(&self) -> Result<(), Self::Err>;
}
