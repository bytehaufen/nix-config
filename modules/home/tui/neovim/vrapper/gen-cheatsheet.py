import glob
import re

from tabulate import tabulate

output_file = "/tmp/cheatsheet.md"
vim_files = sorted(glob.glob("*.vim"))

with open(output_file, "w") as out:
    _ = out.write("# Vrapper Cheatsheet\n\n")

    for vim_file in vim_files:
        with open(vim_file) as f:
            lines = f.readlines()
        # Find doc-title
        title = None
        for line in lines:
            m = re.match(r'\s*"\s*doc-title:\s*(.+)', line)
            if m:
                title = m.group(1).strip()
                break
        if not title:
            title = vim_file  # fallback

        # Extract keybinds and docs
        docs: list[tuple[str, str, str]] = []
        for i, line in enumerate(lines):
            doc_match = re.match(r'\s*"\s*doc:\s*(.+)', line)
            map_match = re.match(
                r"\s*(noremap|nnoremap|vnoremap|xnoremap)\s+(\S+)\s+:(\S+)<cr>", line
            )
            if doc_match and i + 1 < len(lines):
                next_line = lines[i + 1]
                map_match = re.match(
                    r"\s*(noremap|nnoremap|vnoremap|xnoremap)\s+(\S+)\s+:(\S+)<cr>",
                    next_line,
                )
                if map_match:
                    docs.append(
                        (
                            f"`{map_match.group(2)}`",
                            {
                                "nnoremap": "normal",
                                "noremap": "normal",
                                "vnoremap": "visual",
                                "xnoremap": "visual",
                            }.get(map_match.group(1), map_match.group(1)),
                            doc_match.group(1),
                        )
                    )

        if docs:
            # Merge normal/visual duplicates
            from collections import defaultdict

            grouped: dict[tuple[str, str], set[str]] = defaultdict(set)
            for keybind, mode, desc in docs:
                grouped[(keybind, desc)].add(mode)
            merged_docs: list[tuple[str, str, str]] = []
            for (keybind, desc), modes in grouped.items():
                if "normal" in modes and "visual" in modes:
                    merged_docs.append((keybind, "normal/visual", desc))
                else:
                    for mode in sorted(modes):
                        merged_docs.append((keybind, mode, desc))
            _ = out.write(f"## {title}\n\n")
            _ = out.write(
                tabulate(
                    merged_docs,
                    headers=["Keybind", "Mode", "Description"],
                    tablefmt="github",
                )
            )
            _ = out.write("\n\n")
