class AiNativeWorkflow < Formula
  desc "AI-native development workflow CLI (hooks, skills, agents for Claude Code & Copilot CLI)"
  homepage "https://github.com/igorilic/agentic-orchestration"
  url "https://github.com/igorilic/agentic-orchestration/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "23cf4620e3ff91e8f8cfbe22bd2214bc37263d83eb70454bcd5242b698477009"
  license "MIT"
  version "0.3.0"

  # macOS ships bash 3.2; the CLI uses bash 4+ features (declare -A, namerefs).
  depends_on "bash"

  # jq: required throughout for JSON parsing.
  depends_on "jq"

  # gh / glab are optional at install time — the CLI guards each pipeline with
  # require_gh / require_copilot and exits with a clear error. Recommended so
  # `brew info` and `brew missing` surface them.
  depends_on "gh"   => :recommended
  depends_on "glab" => :recommended

  # bats-core is repo-developer only (test suite). Not needed by end users.
  depends_on "bats-core" => :test

  def install
    # Layout:
    #   #{libexec}/ai-native-workflow      real script (shebang patched)
    #   #{libexec}/{scripts,hooks,skills,agents,config,templates}
    #   #{bin}/ai-native-workflow          thin exec wrapper

    # Patch shebang to brew's bash 5 instead of /usr/bin/env bash, which would
    # otherwise resolve to macOS bash 3.2 on most systems.
    inreplace "ai-native-workflow", "#!/usr/bin/env bash",
              "#!#{Formula["bash"].opt_bin}/bash"

    libexec.install "ai-native-workflow"
    libexec.install Dir["scripts", "hooks", "skills", "agents",
                        "config", "templates"]

    # bin/ is a thin wrapper that exec's the libexec script. The CLI's
    # _ANW_SCRIPT_DIR resolver follows symlinks (realpath / greadlink -f /
    # pure-bash fallback) so the wrapper exec has BASH_SOURCE[0] = libexec
    # path, which resolves cleanly. No source patch needed.
    (bin/"ai-native-workflow").write <<~SH
      #!#{Formula["bash"].opt_bin}/bash
      exec "#{libexec}/ai-native-workflow" "$@"
    SH
    chmod 0755, bin/"ai-native-workflow"
  end

  def caveats
    <<~EOS
      The binary is now on your PATH, but hooks and skills are not wired yet.

      Run this once to install Claude Code and Copilot CLI integrations:

        ai-native-workflow install global

      This copies hooks, skills, and agents into:
        ~/.claude/          (Claude Code hooks, skills, agents, settings)
        ~/.copilot/agents/  (Copilot CLI agent definitions, if copilot is on PATH)

      The installer is idempotent: existing files are timestamped-backup'd
      before overwriting, so it is safe to re-run.

      After every `brew upgrade ai-native-workflow`, re-run `install global`
      to pick up updated hooks/skills/agents from the new release.

      Optional env overrides:
        CLAUDE_HOME   override ~/.claude   (default: $HOME/.claude)
        COPILOT_HOME  override ~/.copilot  (default: $HOME/.copilot)
    EOS
  end

  test do
    # Help text is the most stable surface; covers the bash 5 shebang resolution.
    assert_match "ai-native-workflow", shell_output("#{bin}/ai-native-workflow help")

    # Verify _ANW_SCRIPT_DIR resolves to libexec via the wrapper exec.
    output = shell_output("#{bin}/ai-native-workflow __print-script-dir").strip
    assert_equal libexec.realpath.to_s, output
  end
end
