# Logseq Virtual Directory Tree

A Logseq plugin that interprets namespace-separated page names (e.g. `dev/react/hooks`) as virtual directories and provides a file-explorer-style tree UI in the sidebar.

![Main View](docs/images/main.png)

## Features

- **Tree View** -- Visualize your namespaced pages as a folder/file tree in a side panel
- **Folder Navigation** -- Click folders to expand/collapse, click pages to navigate directly
- **Drag & Drop** -- Reorganize your namespace hierarchy by dragging pages and folders
  - Move pages between folders
  - Move entire folders (bulk rename of all child pages)
  - Drop to root to remove namespace prefix
  - Multi-select drag & drop (move multiple items at once)
- **Multi-Select** -- Select multiple pages/folders with Ctrl+Click and Shift+Click
- **Right-Click Context Menu** -- Rename, delete, copy path, or create a child page
- **Inline Rename** -- Rename pages and page-folders directly in the tree
- **Create Page** -- Create new pages, optionally under a selected folder
- **Sorting** -- Sort the tree by name or last-updated date, ascending or descending, with an optional folders-first toggle
- **Reveal Current Page** -- Highlight and scroll to the currently opened page in the tree
- **Expand/Collapse All** -- Quickly expand or collapse the entire tree
- **Independent Panel** -- Side panel does not overlap Logseq's main content area
- **Smart Reload** -- Efficiently refreshes the tree using diff-based updates to preserve expand/collapse state
- **Confirmation Dialogs** -- Review affected pages before any rename, move, or delete operation
- **Theme Support** -- Automatically syncs colors with Logseq's theme (background, text, accent, borders, icons)
- **Persistent State** -- Folder expand/collapse state and sort preferences are saved across reloads
- **Keyboard Support** -- Press Escape to close open dialogs, the sort menu, or inline rename

## Installation

1. In Logseq, go to **Settings > Advanced** and enable **Developer mode**
2. Clone or download this repository
3. Run the build:
   ```bash
   npm install
   npm run build
   ```
4. In Logseq, click **Plugins > Load unpacked plugin** and select this project's root directory
5. A folder icon will appear in the toolbar -- click it to toggle the tree panel

## Usage

### Viewing the Tree

Click the folder icon in the Logseq toolbar to open/close the tree panel on the right side. Pages are organized by their namespace hierarchy:

```
cooking/
  grilling
  sous-vide
dev/
  react/
    hooks
    state
  typescript
memo
```

- Folders appear before pages by default (configurable)
- Journal pages are excluded from the tree
- Pages that are both a namespace parent and a page themselves are shown with a dual icon

### Navigating

- **Click a page name** to navigate to that page in Logseq
- **Click a folder icon** to expand or collapse it
- For pages that are also folders, the icon area toggles expand/collapse while the text area navigates

### Multi-Select

- **Ctrl+Click** (Cmd+Click on macOS) to toggle individual items
- **Shift+Click** to select a range of items
- Selected items are highlighted and can be dragged together

### Drag & Drop

![Drag and Drop](docs/images/drag-and-drop.png)

- **Drag a page** onto a folder to move it (renames the page with the new namespace)
- **Drag a page onto another page** to nest it underneath (the target page becomes a folder)
- **Drag a folder** onto another folder to move the entire subtree (bulk renames all child pages)
- **Drag multiple selected items** to move them all at once (a badge shows the count of items being moved)
- **Drag to the empty area** below the tree to move to root (removes namespace prefix)
- A confirmation dialog shows all affected pages before any rename is executed
- If some renames fail, a result dialog shows which succeeded and which failed
- If a parent rename fails, descendant renames are automatically skipped to prevent orphaned pages

### Context Menu

![Context Menu](docs/images/right-click.png)

Right-click any node to access:

- **Rename** -- Inline rename of pages and page-folders (not pure virtual folders)
- **Delete** -- Delete a page, page-folder subtree, or virtual folder contents with a confirmation dialog
- **Copy path** -- Copy the original page name to clipboard
- **Create page here** -- Create a new child page under any node

### Sorting

![Sort Menu](docs/images/sort.png)

Click the sort icon in the header toolbar to choose a sort order:

- **Name (A-Z / Z-A)** -- Alphabetical sorting
- **Updated (Newest / Oldest)** -- Sort by last-modified date (folder dates are derived from their most recently updated descendant)
  - **Note:** Logseq stores `updatedAt` based on file-system timestamps, not git history. Re-indexing the graph rewrites every page file, which resets all timestamps to the current time and effectively scrambles the sort order. This is a Logseq limitation, not a plugin bug.
- **Folders first** -- Toggle whether folders appear before pages

### Toolbar Actions

The header toolbar provides quick access to:

- **Sort** -- Open the sort menu
- **Reveal** -- Scroll to and highlight the currently opened page
- **Create** -- Create a new page (uses selected folder as prefix if one is selected)
- **Expand All / Collapse All** -- Expand or collapse every folder in the tree
- **Close** -- Hide the panel

## Settings

Open **Plugins > Virtual Directory Tree > Settings** to configure the plugin.

| Setting | Default | Description |
|---------|---------|-------------|
| **Hidden pages** | `card, Favorites, Contents` | Comma-separated list of root-level page names to hide from the tree. Case-insensitive. A name hides the page itself and all pages under it (e.g. `card` hides `card`, `card/deck1`, etc.). |

## Known Limitations

- **File graph only** -- This plugin works with Logseq file-based graphs. DB graphs are not supported.
- **Journal pages excluded** -- Journal pages are automatically excluded from the tree and cannot be managed through this plugin.
- **No undo** -- Rename and delete operations cannot be undone through the plugin. Use Logseq's git versioning if you need to revert.
- **API timing** -- A small delay is inserted between bulk rename and delete operations to avoid overwhelming Logseq's API.
- **Page names with spaces around `/`** -- Logseq allows page names like `A / B`. The tree displays these with trimmed segments but preserves the original name for all API operations.

## Development

### Prerequisites

- Node.js 20.19+, 22.13+, or 24+
- npm

### Setup

```bash
npm install
```

### Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server |
| `npm run build` | Build for production |
| `npm run typecheck` | Run TypeScript type checking without emitting files |
| `npm test` | Run all tests |
| `npm run test:coverage` | Run tests with coverage thresholds |
| `npm run test:visual` | Run Playwright visual smoke tests |
| `npm run test:visual:update` | Update Playwright visual snapshots |
| `npm run test:watch` | Run tests in watch mode |
| `npm run lint` | Run ESLint |
| `npm run format` | Format code with Prettier |
| `npm run format:check` | Check formatting without writing |

### Tech Stack

- TypeScript, Preact, Vite
- HTML5 Drag and Drop API
- Linting: ESLint, Prettier
- Testing: Vitest, jsdom, @testing-library/preact
- CI: GitHub Actions (lint, format, typecheck, coverage tests, build, and non-blocking visual smoke tests on every PR)

### Project Structure

```
src/
  index.tsx            # Plugin entry point
  tree.ts              # Tree data construction logic
  types.ts             # Type definitions
  components/
    App.tsx             # Root component
    TreeView.tsx        # Tree display with sticky header
    TreeNode.tsx        # Recursive tree node
    ConfirmDialog.tsx   # Confirm/loading/result dialogs
    ContextMenu.tsx     # Right-click context menu
    CreatePageDialog.tsx # New page creation dialog
    DeleteDialog.tsx    # Delete confirmation/loading/result dialogs
    InlineRenameInput.tsx # Inline rename input
    SortMenu.tsx        # Sort dropdown menu
  hooks/
    useTree.ts          # Tree state management & smart reload
    useDragDrop.ts      # Drag & drop UI state
    useSelection.ts     # Multi-select state
    useContextMenu.ts   # Context menu state
  utils/
    validation.ts       # Name validation, circular drop detection
    rename.ts           # Rename list generation + execution
    delete.ts           # Delete list generation + execution
    panelLayout.ts      # Panel positioning & main content layout
    themeSync.ts        # Logseq theme color synchronization
    treeDiff.ts         # Diff-based tree update for smart reload
    clipboard.ts        # Clipboard copy with Logseq sandbox fallback
    debounce.ts         # Custom debounce function
  __tests__/            # Unit and integration tests
tests/
  visual/               # Playwright visual smoke tests
scripts/
  extract-release-notes.mjs # Release note extraction helper
```

## Contributing

Pull requests are welcome! However, please note:

- This is a personal project maintained in my spare time
- Response times may vary — please be patient
- Not all PRs or feature requests may be accepted

Please ensure your PR passes all CI checks (lint, format, tests) before requesting a review.

## License

MIT
