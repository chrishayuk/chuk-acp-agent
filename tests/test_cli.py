"""Tests for CLI module."""

import sys
from unittest.mock import patch

import pytest

from chuk_acp_agent import cli


class TestCLI:
    """Test CLI functionality."""

    def test_print_version(self, capsys):
        """Test print_version outputs version."""
        cli.print_version()
        captured = capsys.readouterr()
        assert "chuk-acp-agent" in captured.out
        # Should have some version number
        assert len(captured.out.strip()) > len("chuk-acp-agent")

    def test_print_help(self, capsys):
        """Test print_help outputs help text."""
        cli.print_help()
        captured = capsys.readouterr()
        assert "Usage:" in captured.out
        assert "Commands:" in captured.out
        assert "version" in captured.out
        assert "help" in captured.out

    def test_main_no_args(self, capsys):
        """Test main with no arguments."""
        with patch.object(sys, "argv", ["chuk-acp-agent"]):
            with pytest.raises(SystemExit) as exc_info:
                cli.main()
            assert exc_info.value.code == 1

        captured = capsys.readouterr()
        assert "Usage:" in captured.out

    def test_main_version_command(self, capsys):
        """Test main with version command."""
        with patch.object(sys, "argv", ["chuk-acp-agent", "version"]):
            cli.main()

        captured = capsys.readouterr()
        assert "chuk-acp-agent" in captured.out

    def test_main_help_command(self, capsys):
        """Test main with help command."""
        with patch.object(sys, "argv", ["chuk-acp-agent", "help"]):
            cli.main()

        captured = capsys.readouterr()
        assert "Usage:" in captured.out
        assert "Commands:" in captured.out

    def test_main_unknown_command(self, capsys):
        """Test main with unknown command."""
        with patch.object(sys, "argv", ["chuk-acp-agent", "unknown"]):
            with pytest.raises(SystemExit) as exc_info:
                cli.main()
            assert exc_info.value.code == 1

        captured = capsys.readouterr()
        assert "Unknown command: unknown" in captured.out
        assert "Usage:" in captured.out
