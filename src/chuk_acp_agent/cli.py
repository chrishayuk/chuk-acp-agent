#!/usr/bin/env python3
"""
CLI for chuk-acp-agent.

Provides commands for scaffolding and running agents.
"""

import sys


def main() -> None:
    """Main CLI entry point."""
    if len(sys.argv) < 2:
        print_help()
        sys.exit(1)

    command = sys.argv[1]

    if command == "version":
        print_version()
    elif command == "help":
        print_help()
    else:
        print(f"Unknown command: {command}")
        print_help()
        sys.exit(1)


def print_version() -> None:
    """Print version information."""
    from chuk_acp_agent import __version__

    print(f"chuk-acp-agent {__version__}")


def print_help() -> None:
    """Print help message."""
    print("""
chuk-acp-agent - Opinionated agent kit for building ACP agents

Usage:
    chuk-acp-agent <command> [args...]

Commands:
    version             Show version information
    help                Show this help message

Examples:
    chuk-acp-agent version
    chuk-acp-agent help

Documentation:
    https://github.com/chrishayuk/chuk-acp-agent

Quick Start:
    1. Install: pip install chuk-acp-agent
    2. Create agent.py (see examples/)
    3. Run: python agent.py
    4. Configure in editor (Zed, VS Code, etc.)

See examples/ directory for sample agents.
""")


if __name__ == "__main__":
    main()
