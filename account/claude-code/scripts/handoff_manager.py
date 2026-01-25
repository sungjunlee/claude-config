#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["pyyaml", "tiktoken"]
# ///
"""
Handoff Manager for Claude Code
Manages handoff document creation, retrieval, and archiving.
Platform-independent alternative to symbolic links.
"""

import os
import sys
import json

try:
    import yaml
except ImportError:
    yaml = None
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class HandoffManager:
    """Manages Claude Code handoff documents and metadata."""

    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.handoff_dir = self.project_root / "docs" / "handoff"
        self.archive_dir = self.handoff_dir / "archive"
        self.metadata_file = self.handoff_dir / ".current"
        self.max_recent_handoffs = 5

        # Ensure directories exist
        self.handoff_dir.mkdir(parents=True, exist_ok=True)
        self.archive_dir.mkdir(exist_ok=True)

    def create_handoff(self, content: str, mode: str = "quick") -> str:
        """
        Create a new handoff document and update metadata.

        Args:
            content: Handoff document content
            mode: Handoff mode (quick, detailed, team)

        Returns:
            Path to created handoff file
        """
        timestamp = datetime.now().strftime("%Y%m%d-%H%M")
        filename = f"HANDOFF-{timestamp}.md"
        filepath = self.handoff_dir / filename

        # Write handoff content
        try:
            filepath.write_text(content, encoding="utf-8")
        except OSError as e:
            raise OSError(f"Failed to write handoff file {filepath}: {e}")

        # Update metadata
        metadata = {
            "current": filename,
            "created": datetime.now().isoformat(),
            "model": self._get_current_model(),
            "token_estimate": self._estimate_tokens(content),
            "session_duration": self._calculate_session_duration(),
            "files_modified": self._count_modified_files(content),
            "mode": mode,
        }

        self._write_metadata(metadata)

        # Archive old handoffs if needed
        self._archive_old_handoffs()

        return str(filepath)

    def get_latest_handoff(self) -> Optional[str]:
        """
        Get the path to the latest handoff document.

        Returns:
            Path to latest handoff or None if no handoffs exist
        """
        if not self.metadata_file.exists():
            return None

        metadata = self._read_metadata()
        if metadata and "current" in metadata:
            handoff_path = self.handoff_dir / metadata["current"]
            if handoff_path.exists():
                return str(handoff_path)

        return None

    def list_handoffs(self, include_archived: bool = False) -> List[Dict]:
        """
        List all available handoff documents.

        Args:
            include_archived: Whether to include archived handoffs

        Returns:
            List of handoff information dictionaries
        """
        handoffs = []

        # List recent handoffs
        for handoff_file in sorted(self.handoff_dir.glob("HANDOFF-*.md"), reverse=True):
            handoffs.append(self._get_handoff_info(handoff_file))

        # List archived handoffs if requested
        if include_archived:
            for handoff_file in sorted(
                self.archive_dir.glob("HANDOFF-*.md"), reverse=True
            ):
                info = self._get_handoff_info(handoff_file)
                info["archived"] = True
                handoffs.append(info)

        return handoffs

    def load_handoff(self, filename: Optional[str] = None) -> Optional[Dict]:
        """
        Load a handoff document and its metadata.

        Args:
            filename: Specific handoff file to load (uses latest if None)

        Returns:
            Dictionary with handoff content and metadata
        """
        if filename:
            # Look for specific file
            handoff_path = self.handoff_dir / filename
            if not handoff_path.exists():
                handoff_path = self.archive_dir / filename
                if not handoff_path.exists():
                    return None
        else:
            # Use latest
            latest = self.get_latest_handoff()
            if not latest:
                return None
            handoff_path = Path(latest)

        content = handoff_path.read_text(encoding="utf-8", errors="replace")
        info = self._get_handoff_info(handoff_path)

        return {"content": content, "metadata": info}

    def verify_handoff(self, filename: Optional[str] = None) -> Dict:
        """
        Verify handoff validity and check for conflicts.

        Args:
            filename: Specific handoff to verify (uses latest if None)

        Returns:
            Verification results dictionary
        """
        handoff = self.load_handoff(filename)
        if not handoff:
            return {"valid": False, "error": "Handoff not found"}

        results = {
            "valid": True,
            "warnings": [],
            "age_days": self._calculate_age(handoff["metadata"]["created"]),
            "files_changed": [],
            "conflicts": [],
        }

        # Check age
        if results["age_days"] > 7:
            results["warnings"].append(f"Handoff is {results['age_days']} days old")

        # Extract and verify mentioned files
        mentioned_files = self._extract_mentioned_files(handoff["content"])
        for filepath in mentioned_files:
            full_path = self.project_root / filepath
            if not full_path.exists():
                results["files_changed"].append(f"{filepath} (deleted)")
            elif self._file_modified_since(full_path, handoff["metadata"]["created"]):
                results["files_changed"].append(f"{filepath} (modified)")

        # Check for git conflicts
        conflicts = self._check_git_conflicts()
        if conflicts is None:
            results["valid"] = False
            results["warnings"].append(
                "Unable to check git conflicts (git unavailable)"
            )
        elif conflicts:
            results["conflicts"] = conflicts

        return results

    def _write_metadata(self, metadata: Dict):
        """Write metadata to .current file."""
        if yaml is None:
            raise RuntimeError("pyyaml is required (pip install pyyaml)")
        with open(self.metadata_file, "w", encoding="utf-8") as f:
            yaml.dump(metadata, f, default_flow_style=False)

    def _read_metadata(self) -> Optional[Dict]:
        """Read metadata from .current file."""
        if not self.metadata_file.exists():
            return None

        if yaml is None:
            raise RuntimeError("pyyaml is required (pip install pyyaml)")
        with open(self.metadata_file, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    def _get_handoff_info(self, filepath: Path) -> Dict:
        """Extract information from a handoff file."""
        created = datetime.fromtimestamp(filepath.stat().st_mtime)
        content = filepath.read_text(encoding="utf-8", errors="replace")

        # Extract summary from content (first heading after title)
        summary = "No summary available"
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("## 🎯 Session Summary"):
                if i + 1 < len(lines):
                    summary = lines[i + 1].strip()
                break

        return {
            "filename": filepath.name,
            "path": str(filepath),
            "created": created.isoformat(),
            "size": filepath.stat().st_size,
            "summary": summary,
            "token_estimate": self._estimate_tokens(content),
        }

    def _estimate_tokens(self, content: str) -> int:
        """Estimate token count for content."""
        try:
            import tiktoken

            # Use cl100k_base encoding (GPT-4, Claude compatible estimate)
            encoding = tiktoken.get_encoding("cl100k_base")
            return len(encoding.encode(content))
        except ImportError:
            print("Warning: tiktoken not installed; using fallback token estimate", file=sys.stderr)
            return len(content) // 4
        except (ValueError, TypeError, AttributeError) as e:
            # Log common encoding issues but don't crash
            print(
                f"Warning: Token estimation failed ({e}), using fallback",
                file=sys.stderr,
            )
            return len(content) // 4

    def _get_current_model(self) -> str:
        """Get current Claude model from environment or config."""
        # This would integrate with Claude Code's actual model selection
        return os.environ.get("CLAUDE_MODEL", "claude-3-5-sonnet")

    def _calculate_session_duration(self) -> int:
        """Calculate session duration in minutes."""
        # This would integrate with actual session tracking
        # For now, return a placeholder
        return 0

    def _count_modified_files(self, content: str) -> int:
        """Count number of modified files mentioned in handoff."""
        count = 0
        for line in content.split("\n"):
            if line.strip().startswith("- ") and (
                "modified" in line.lower() or "changed" in line.lower()
            ):
                count += 1
        return count

    def _archive_old_handoffs(self):
        """Archive handoffs beyond the retention limit."""
        handoffs = sorted(self.handoff_dir.glob("HANDOFF-*.md"))

        if len(handoffs) > self.max_recent_handoffs:
            for handoff in handoffs[: -self.max_recent_handoffs]:
                shutil.move(str(handoff), str(self.archive_dir / handoff.name))

    def _calculate_age(self, created_str: str) -> int:
        """Calculate age of handoff in days."""
        created = datetime.fromisoformat(created_str)
        return (datetime.now() - created).days

    def _extract_mentioned_files(self, content: str) -> List[str]:
        """Extract file paths mentioned in handoff content."""
        files = []
        in_files_section = False

        for line in content.split("\n"):
            if "Modified Files" in line or "Files Modified" in line:
                in_files_section = True
                continue
            elif line.startswith("##") and in_files_section:
                in_files_section = False
            elif in_files_section and line.strip().startswith("-"):
                # Extract filename from lines like "- src/main.py - modified"
                parts = line.strip("- ").split(" - ")
                if parts:
                    files.append(parts[0])

        return files

    def _file_modified_since(self, filepath: Path, since_str: str) -> bool:
        """Check if file was modified since given timestamp."""
        since = datetime.fromisoformat(since_str)
        mtime = datetime.fromtimestamp(filepath.stat().st_mtime)
        return mtime > since

    def _check_git_conflicts(self) -> Optional[List[str]]:
        """Check for git merge conflicts."""
        conflicts = []
        try:
            result = subprocess.run(
                ["git", "diff", "--name-only", "--diff-filter=U"],
                capture_output=True,
                text=True,
                cwd=self.project_root,
            )
            if result.returncode != 0:
                return None
            if result.stdout:
                conflicts = result.stdout.strip().split("\n")
        except (subprocess.SubprocessError, FileNotFoundError, OSError):
            return None  # Git not available or not a git repo

        return conflicts


def main():
    """CLI interface for handoff manager."""
    import argparse

    parser = argparse.ArgumentParser(description="Claude Code Handoff Manager")
    parser.add_argument(
        "command",
        choices=["create", "latest", "list", "verify"],
        help="Command to execute",
    )
    parser.add_argument("--content", help="Content for create command")
    parser.add_argument(
        "--mode",
        default="quick",
        choices=["quick", "detailed", "team"],
        help="Handoff mode",
    )
    parser.add_argument("--file", help="Specific handoff file")
    parser.add_argument(
        "--archived", action="store_true", help="Include archived handoffs in list"
    )

    args = parser.parse_args()

    manager = HandoffManager()

    if args.command == "create":
        if not args.content:
            print("Error: --content required for create command")
            return
        path = manager.create_handoff(args.content, args.mode)
        print(f"Created handoff: {path}")

    elif args.command == "latest":
        latest = manager.get_latest_handoff()
        if latest:
            print(f"Latest handoff: {latest}")
        else:
            print("No handoffs found")

    elif args.command == "list":
        handoffs = manager.list_handoffs(args.archived)
        for h in handoffs:
            archived = " (archived)" if h.get("archived") else ""
            print(f"{h['filename']}{archived}: {h['summary']}")

    elif args.command == "verify":
        results = manager.verify_handoff(args.file)
        print(f"Valid: {results['valid']}")
        if results.get("warnings"):
            print("Warnings:")
            for w in results["warnings"]:
                print(f"  - {w}")
        if results.get("files_changed"):
            print("Files changed:")
            for f in results["files_changed"]:
                print(f"  - {f}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}")
        exit(1)
