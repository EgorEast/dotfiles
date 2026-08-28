-- Dart analysis server (ships with the Dart / Flutter SDK). Gives diagnostics,
-- code actions / quickfixes, rename, go-to-definition, hover, completion.
-- No Flutter run tooling here on purpose.
return {
  cmd = { "dart", "language-server", "--protocol=lsp" },
  filetypes = { "dart" },
  root_markers = { "pubspec.yaml", ".git" },
  init_options = {
    onlyAnalyzeProjectsWithOpenFiles = true,
    suggestFromUnimportedLibraries = true,
    closingLabels = true,
    outline = true,
  },
  settings = {
    dart = {
      completeFunctionCalls = true,
      showTodos = true,
      updateImportsOnRename = true,
      enableSnippets = true,
      analysisExcludedFolders = { ".dart_tool", "build", ".fvm" },
    },
  },
}
