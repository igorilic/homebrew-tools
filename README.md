# homebrew-tools

Personal Homebrew tap for [@igorilic](https://github.com/igorilic)'s CLI tools.

## Usage

```bash
brew tap igorilic/tools
brew install <formula>
```

## Available formulas

### ai-native-workflow

Multi-agent CLI for AI-native test-driven development across Claude Code and GitHub Copilot CLI.

```bash
brew install igorilic/tools/ai-native-workflow
ai-native-workflow install global
```

After install, run `ai-native-workflow install global` once to wire hooks, skills, and agents into `~/.claude/` and `~/.copilot/`. Re-run after every `brew upgrade ai-native-workflow` to pick up changes from the new release.

Source: [igorilic/agentic-orchestration](https://github.com/igorilic/agentic-orchestration)

## License

Each formula tracks its upstream license. The tap itself (formula recipes) is MIT.
