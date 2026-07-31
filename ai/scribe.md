---
name: scribe
description: Use this skill when the user wants to save or write back a refined specification to its original markdown file after a chat discussion. Triggers on "/scribe", "write it back", "save the spec", "update the file", or when the user signals the discussion is done and wants to persist the result. Always use this skill when the user invokes /scribe, even with a file path argument.
version: 1.0.0
---

# Scribe

Append the final refined specification to its original markdown file after a chat discussion.

## When This Skill Applies

The user has been refining a specification through chat. The conversation contains an original markdown file and a series of changes discussed. The user now wants to persist the final version.

## Arguments

An optional file path can be passed as an argument (e.g., `/scribe path/to/spec.md`). If provided, use that path. Otherwise, auto-detect the target file from the conversation context — look for the markdown file the user provided at the start of the session.

## Steps

1. **Identify the target file** — use the argument if provided; otherwise find the markdown file introduced by the user earlier in the conversation. if multiple files are given, use last one.
2. **Reconstruct the final spec** — review the full conversation history and extract all agreed-upon refinements and changes
3. **Append to the file** — do not modify or remove original contents; append the final refined specification at the end of the file
4. **Report back** with two things:
   - What the user originally requested (the intent behind this session)
   - A brief summary of what changed from the original spec to the final version (additions, removals, modifications)
5. **Backup the file** — copy the updated file into the project's `.claude/chats` directory as an archive. Generate a 3-5 word kebab-case summary of the chat session (e.g., `add-scribe-skill`, `refactor-auth-flow`). Name the backup `<YYYYMMDD>-<chat-summary>.md` (e.g., `20240318-add-scribe-skill.md`). The project root is the working directory of the current session.

## Output Format

```
Appended to: <file path>

**Request:** <what the user say>

**Changes:** <summary of the changes>
```
