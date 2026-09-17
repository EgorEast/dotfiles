-- sourcekit-lsp ships with the Swift toolchain (Xcode CLT / swift.org), so
-- there's nothing for mason to install here (same deal as dartls).
return {
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift" },
  root_markers = { "Package.swift", "buildServer.json", ".git" },
}
